# encoding: utf-8

require 'nokogiri'
require 'timecop'

require 'rack'
require 'airbrake'

class String
  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end
end

class MovieSyncer
  attr_accessor :movies, :place, :date

  def initialize(options)
    self.place = options.delete(:place)
    self.movies = options.delete(:movies)
    self.date = options[:date]
  end

  def self.now
    @now ||= Time.zone.now.change(sec: 0)
  end

  def self.finded_movies
    @finded_movies ||= []
  end

  def sync
    puts "#{place}: импорт сеансов"
    now = Time.zone.now.change(sec: 0)
    bar = ProgressBar.new(movies.values.map(&:count).sum)
    movies.each do |title, seances|
      next unless title.squish
      if (movie = find_movie_by(title.squish)) && (cinematheatre = find_similar_cinematheatre_by(place.squish))
        MovieSyncer.finded_movies << movie
        showings = Showing.where(
          id: Showing.search {
            with(:afisha_id, movie.id)
            fulltext(place) {
              fields(:place, :organization_title)
            }
            paginate(per_page: '100000')
          }.results.map(&:id)
        )

        seances.each do |seance|
          seance.each do |k,v| v.squish! if v.is_a?(String) end

          Timecop.freeze(MovieSyncer.now) do
            if showing = showings.find_by_hall_and_starts_at_and_price_min(seance[:hall],
                                                                           seance[:starts_at],
                                                                           seance[:price_min],
                                                                           seance[:price_max])
              showing.update_attributes! seance
              showing.touch
            else
              showing = Showing.new(
                hall: seance[:hall],
                starts_at: seance[:starts_at],
                price_min: seance[:price_min],
                price_max: seance[:price_max],
                afisha_id: movie.id
              ).tap do |s|
                s.place = cinematheatre.title
                s.organization_id = cinematheatre.id
              end
              showing.attributes = seance
              showing.save!
            end
          end
          bar.increment!
        end
        showings.where('starts_at > ?', now).where('updated_at <> ?', now).destroy_all
      else
        bar.increment! seances.count
      end
    end

    message = I18n.localize(Time.now, format: :short) + " Импорт сеансов '#{place}'"
    message += " на #{date}" if date.present?
    message += " выполнен."
    #MyMailer.delay(queue: 'mailer').send_movie_sync_complete(message)
  end

  private

    def find_movie_by(title)
      title.squish!
      MovieFixer.all.each do |movie_fixer|
        title.gsub!(movie_fixer.from, movie_fixer.to)
      end
      Afisha.find_by_title(title) || find_similar_movie_by(title)
    end

    def find_similar_movie_by(title)
      similar_movies = Afisha.search{fulltext(title){fields(:title)}}.results
      if similar_movies.one?
        puts "Найден похожий фильм '#{title}' -> '#{similar_movies.first.title}'"
      end
      if similar_movies.blank?
        text = "Не могу найти фильм '#{title}': [#{place}]"
        puts text
        message = I18n.localize(Time.now, format: :short) + " " + text
        MyMailer.delay(queue: 'mailer').send_movie_sync_error(message)
      end
      if similar_movies.many?
        text = "Нашел больше одной афиши для фильма '#{title}': [#{place}]"
        puts text
        message = I18n.localize(Time.now, format: :short) + " " + text
        MyMailer.delay(queue: 'mailer').send_movie_sync_error(message)
      end
      similar_movies.first
    end

    def find_similar_cinematheatre_by(cinema_title)
      similar_cinematheatre = Organization.where(title: cinema_title)
      unless similar_cinematheatre.any?
        similar_cinematheatre = Organization.search{fulltext(cinema_title){fields(:title)}; fulltext('Кинотеатры'){fields(:category)}}.results
      end
      unless similar_cinematheatre.one?
        puts "Кинотеатр '#{cinema_title}' не найден"

        message = I18n.localize(Time.now, format: :short) + " Не могу найти кинотеатр '#{cinema_title}'"
        Airbrake.notify(Exception.new(message))
      end
      similar_cinematheatre.first
    end

end

class GoodwinCinemaGroup
  attr_accessor :cinema_name, :schedule_url
  def initialize(cinema_name, url)
    @cinema_name = cinema_name
    @schedule_url = url
  end

  def sync
    puts cinema_name
    [0, 1, 2].each do |day_offset|
      date = I18n.l(Time.zone.now + day_offset.day, format: '%d.%m.%Y')
      url = schedule_url+date
      response = Curl.get(url).body_str
      if response.is_json?
        json = JSON.parse(response.force_encoding('cp1251').encode('utf-8', undef: :replace))
        movies = {}
        bar = ProgressBar.new(json['films'].count)
        json['films'].each do |movie|
          title = movie['title'].gsub(',&nbsp;', '').gsub(/\(2D|\(3D|HFR/, '').gsub(/\d+\+\)/, '').gsub(/\s+\(\z/, '').squish
          movies[title] ||= []
          movie['halls'].each do |hash|
            hash['sessions'].each do |session|
              time = session['time']
              starts_at = Time.zone.parse("#{date} #{time}")
              price_min = session['price']
              movies[title] << {
                starts_at: starts_at,
                price_min: price_min,
                price_max: price_min
              }
            end
          end
          bar.increment!
        end
        puts "Импорт информации от #{date} (#{url})"
        MovieSyncer.new(place: cinema_name, movies: movies, date: date).sync
      else
        Airbrake.notify(error_class: "Rake Task", error_message: "Неверный формат ответа от кинотеатра #{cinema_name}")
      end
    end
  end
end

class SevastopolCinema
  attr_accessor :cinema_name, :schedule_url , :price_min, :price_max

  def initialize(cinema_name, url, price_min, price_max)
    @cinema_name = cinema_name
    @schedule_url = url
    @price_min = price_min
    @price_max = price_max
  end

  def sync
    movies = {}

    timetable = Nokogiri::HTML(Curl.get(schedule_url).body_str).css('.timelist div')
    bar = ProgressBar.new(timetable.count)
    puts "#{cinema_name}: парсинг"

    timetable.css('a').map(&:text).uniq.map{ |title| movies[title] = [] }

    timetable.each do |seance|
      title = seance.css('a').text
      date = Date.today
      time = seance.css('span').text
      hall = seance.css('span').first.attributes['class'].value == 'tech hall' ? 'Зал №1' : '3D зал'
      movies[title] << {
        starts_at: Time.zone.parse("#{date} #{time}"),
        hall: hall,
        price_min: price_min,
        price_max: price_max
      }
      bar.increment!
    end

    MovieSyncer.new(place: cinema_name, movies: movies).sync
  end
end
namespace :sync do

  desc "Sync movie seances from http://goodwincinema.ru"
  task goodwin: :environment do
    GoodwinCinemaGroup.new('Goodwin cinema, кинотеатр','http://goodwincinema.ru/schedule/?ajax=1&date=' ).sync
  end

  desc "Sync movie seances from http://kino-polis.ru"
  task kinopolis: :environment do
    GoodwinCinemaGroup.new('Kinopolis, кинотеатр', 'http://kino-polis.ru/schedule/?ajax=1&date=' ).sync
  end

  desc "Sync movie seances from http://kinomax.tomsk.ru"
  task kinomax: :environment do
    GoodwinCinemaGroup.new('Киномакс, кинотеатр', 'http://kinomax.tomsk.ru/schedule/?ajax=1&date=' ).sync
  end

  desc "Sync movie seances from http://fakel.net.ru"
  task fakel: :environment do
    url = 'http://fakel.net.ru/cinema/schedule'
    page = Nokogiri::HTML(Curl.get(url).body_str)
    puts 'Fakel: парсинг'
    movies = {}
    day_nodes = page.css('.av_tab_section')
    bar = ProgressBar.new(day_nodes.count)
    day_nodes.each do |day_node|
      date = day_node.css('div.tab').text.match(/((\d{2})\.(\d{2})\.(\d{4}))/)[1]
      day_node.css('td').map(&:text).each_slice(3) do |seance|
        time, title, price_min = seance
        starts_at  =  Time.zone.parse("#{date} #{time}")
        title = title.gsub(/\(?2D\)?|\(?3D\)?|\(?HFR\)?/, '').gsub(/\d+\+\)/, '').gsub(/\u00A0+/, '').squish
        movies[title] ||= []
        movies[title] << {starts_at: starts_at, price_min: price_min, price_max: price_min }
      end
      bar.increment!
    end
    MovieSyncer.new(place: '"Fакел", развлекательный комплекс', movies: movies).sync
  end

  desc "Sync movie seances from http://kinomax.tomsk.ru"
  task kinomax_old: :environment do
    host = 'http://kinomax.tomsk.ru'
    url = "#{host}/schedule/"
    movies = {}

    timetable = Nokogiri::HTML(Curl.get(url).body_str).css('.tableTabContainer a')
    bar = ProgressBar.new(timetable.count)
    puts 'Киномакс: парсинг'

    timetable.each do |day_tile|
      day_schedule_path = day_tile.attribute('data-url').value
      date = day_schedule_path.match(/\d{2}.\d{2}.\d{4}/)
      day_schedule_page = Nokogiri::HTML(Net::HTTP.post_form(URI.parse(host + day_schedule_path), {}).body.force_encoding('cp1251'))

      day_schedule_page.css('h2.sectionHeader2').each do |hall_html|
        hall  = hall_html.text
        hall_html.next_element.css('div.hallContainer').each do |film|
          title = film.css('h3 a').text.squish
          three_d = title.match(/\(?3D\)?/)
          title = title.gsub(/\(?3D\)?\b|\(?2D\)?|\(?IMAX\)?|\(?HFR\)?|\(?\d+\+\)?/, '').squish
          movies[title] ||= []
          film.css('a.timeLineItem').each do |seans|
            next if seans['class'].match(/session-already-past|session-disabled/)
            time = seans.css('u').first.text
            seans_id = seans['href'].match(/\d+/)
            prices = day_schedule_page.css("#sessionTooltip-#{seans_id}").first.css('table.sessionTooltipTable').first.css('td.tal')[1].text
            price_min = prices.match(/\d+/).to_a.map(&:to_i).min
            price_max = prices.match(/\d+/).to_a.map(&:to_i).max
            movies[title] << {
              starts_at: Time.zone.parse("#{date} #{time}"),
              hall: [hall, three_d].join(' ').squish,
              price_min: price_min,
              price_max: price_max
            }
          end
        end
      end
      bar.increment!
    end
    MovieSyncer.new(place: 'Киномакс, кинотеатр', movies: movies).sync
  end

  desc "Sync movie seances from http://kinomir.tom.ru"
  task kinomir: :environment do
    host = 'http://kinomir.tom.ru'
    url = "#{host}/schedule/"
    movies = {}

    timetable = Nokogiri::HTML(Curl.get(url).body_str).css('.schedule a')
    bar = ProgressBar.new(timetable.count)
    puts 'Киномир: парсинг'

    timetable.each do |day_tile|
      day_schedule_path = day_tile.attribute('href').value
      date = day_schedule_path.match(/\d{2}.\d{2}.\d{4}/)
      day_schedule_page = Nokogiri::HTML(Curl.get(host+day_schedule_path).body_str)
      day_schedule_page.css('.raspisanie-table').each do |table|
        hall = table.css('thead tr td:first h1').text
        table.css('tbody tr td div .container .content').each do |seance|
          title = seance.css('h1').text
          three_d = title.match(/((?:в 3D)|3D)/).try(:[], 1)
          title = title.gsub(/((?:в 3D)\b|3D\b)/,'').squish
          title = title.gsub(/\s\(?3D\)?\b|\(?2D\)?|\(?HFR\)?|\(?\d+\+\)?/,'').squish
          next if title =~ /^Non-stop [[:alpha:]]+ зал$/
          movies[title] ||= []
          seance.parent.parent.parent.parent.css('td:nth-child(2) > div > div').each do |i|
            if i['class'] == 'show-time'
              time = i.css('a').text
              amount = i.next_element.css('table td:nth-child(2)').text
              if time.split(':').first == '24'
                hour = '00'
                min = time.split(':').last
                time = hour + ':' + min
                Time.parse(time)+1.day
              else
                Time.parse(time)
              end
              movies[title] << {
                starts_at: Time.zone.parse("#{date} #{time}"),
                hall: [hall, three_d].join(' ').squish,
                price_min: amount.to_i,
                price_max: amount.to_i
              }
            end
          end
        end
      end
      bar.increment!
    end

    MovieSyncer.new(place: 'Киномир, кинотеатр', movies: movies).sync
  end

  desc "Sync movie seances from http://afisha.sevastopol.press/kinoteatr-pobeda"
  task pobeda: :environment do
    SevastopolCinema.new('Кинотеатр «Победа»','http://afisha.sevastopol.press/kinoteatr-pobeda', 100, 150).sync
  end

  desc "Sync movie seances from http://afisha.sevastopol.press/kinoteatr-musson"
  task musson: :environment do
    SevastopolCinema.new('Муссон','http://afisha.sevastopol.press/kinoteatr-musson', 110, 300).sync
  end

  desc "Sync movie seances from http://afisha.sevastopol.press/kinoteatr-musson"
  task apelsin: :environment do
    SevastopolCinema.new('Апельсин, торгово-развлекательный центр','http://afisha.sevastopol.press/kinoteatr-apelsin', 90, 220).sync
  end
end

task sync: ['sync:goodwin', 'sync:kinopolis', 'sync:kinomax', 'sync:kinomir'] do
  organiation_ids = Organization.where(title: [
    'Goodwin cinema, кинотеатр',
    '"Fакел", развлекательный комплекс',
    'Киномакс, кинотеатр', 'Киномир, кинотеатр',
    'Kinopolis, кинотеатр'
  ]).map(&:id)
  bad_showings = Showing.where(
    afisha_id: MovieSyncer.finded_movies.map(&:id).uniq)
      .where(:organization_id => organiation_ids)
      .where('starts_at > ?', MovieSyncer.now)
      .where('updated_at <> ?', MovieSyncer.now)
  bad_showings.destroy_all
end
