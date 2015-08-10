# encoding: utf-8

class AfishaDecorator < ApplicationDecorator
  include AutoHtmlFor
  include OpenGraphMeta
  include ApplicationHelper

  decorates :afisha

  delegate :distribution_starts_on, :distribution_ends_on, :distribution_starts_on?, :distribution_ends_on?, :kind, :to => :afisha

  attr_accessor :showings

  def initialize(afisha, showings = nil)
    super
    @showings = showings ? ShowingDecorator.decorate(showings) : ShowingDecorator.decorate(afisha.showings.actual)
  end

  def open_graph_meta_tags
    tags
  end

  def truncated_title_link(length, options = {})
    separator = options.delete(:separator) || ' '
    anchor = options.delete(:anchor)

    if afisha.title.length > length
      h.link_to(afisha.title.truncated(length, separator), h.afisha_show_path(afisha, anchor: anchor), options.merge(:title => afisha.title))
    else
      h.link_to(afisha.title, h.afisha_show_path(afisha, anchor: anchor), options)
    end
  end

  def poster_with_link(width, height, options = {})
    h.link_to h.afisha_show_path(afisha), options do
      if afisha.poster_url.present?
        h.image_tag(h.resized_image_url(afisha.poster_url, width, height, { crop: '!', orientation: 'n' }), size: "#{width}x#{height}", alt: afisha.title)
      else
        h.image_tag('public/stub_poster.png', size: '178x240', alt: :poster)
      end
    end
  end

  def afisha_place(options = {})
    length = options.delete(:length) || 45
    separator = options.delete(:separator) || ' '

    only_path_value = options.delete(:only_path)
    only_path = only_path_value.nil? ? true : only_path_value

    max_lenght = length
    place_output = ""
    places.each_with_index do |place, index|
      place_title = place.organization ? place.organization.title : place.title
      place_link_title = place_title.dup
      place_title = place_title.gsub(/,.*/, '')
      place_title = place_title.truncate(max_lenght, :separator => separator)
      max_lenght -= place_title.size
      if place.organization
        place_output += h.link_to(place_title.text_gilensize, h.organization_path(place.organization, :only_path => only_path), options.merge(:title => place_link_title.text_gilensize))
      else
        place_output += place_link_title.blank? ? place_title.text_gilensize : h.content_tag(:abbr, place_title.text_gilensize, :title => place_link_title.text_gilensize)
      end
      break if max_lenght < 3
      place_output += ", " if index < places.size - 1
    end
    h.raw place_output
  end

  def places
    [].tap do |array|
      if showings.any?
        showings.compact.map { |showing| showing.organization ? showing.organization : showing.place }.uniq.each do |place|
          array << (place.is_a?(Organization) ? PlaceDecorator.new(:organization => place) : PlaceDecorator.new(:title => place,
                                                                       :latitude => afisha.showings.where(:place => place).first.latitude,
                                                                       :longitude => afisha.showings.where(:place => place).first.longitude))
        end
      else
        last_showoing = afisha.showings.last
        return [] unless last_showoing
        place = last_showoing.organization ? last_showoing.organization : last_showoing.place
        array << (place.is_a?(Organization) ? PlaceDecorator.new(:organization => place) : PlaceDecorator.new(:title => place,
                                                                                   :latitude => last_showoing.latitude,
                                                                                   :longitude => last_showoing.longitude))
      end
    end
  end

  def afisha_distribution?
    afisha.distribution_starts_on? || afisha.distribution_ends_on? || afisha.constant?
  end

  def afisha_actual?
    @actual ||= afisha.showings.actual.count > 0
  end

  def human_distribution
    if distribution_starts_on? && distribution_ends_on?
      return "С #{distribution_starts_on.day} по #{I18n.l(distribution_ends_on, :format => '%e %B')}".squish if  distribution_starts_on.month == distribution_ends_on.month
      return "С #{I18n.l(distribution_starts_on, :format => '%e %B')} по #{I18n.l(distribution_ends_on, :format => '%e %B')}".squish
    elsif distribution_starts_on?
      return "С #{I18n.l(distribution_starts_on, :format => '%e %B')}".squish
    elsif distribution_ends_on?
      return "До #{I18n.l(distribution_ends_on, :format => '%e %B')}".squish
    end
  end

  def human_when
    nealest_showing = showings.any? ? showings.first : ShowingDecorator.new(afisha.showings.last)
    return "Время проведения неизвестно" unless nealest_showing.showing
    if afisha_actual?
      if afisha.constant?
        return afisha.exhibition? ? 'Постоянная экспозиция' : 'Постоянное мероприятие'
      end
      return human_distribution if afisha_distribution?
    else
      case afisha.kind
      when *['movie']
        if afisha_distribution?
          return human_distribution if afisha.distribution_starts_on >= Date.today
          return "Было в прокате до #{nealest_showing.e_B(nealest_showing.starts_at)}"
        else
          return "Последний показ был #{nealest_showing.e_B(nealest_showing.starts_at)}"
        end
      when *['exhibition']
        return "Выставка закончилась #{nealest_showing.e_B(nealest_showing.starts_at)}"
      end
    end
    nealest_showing.actual? ? nealest_showing.human_when : "Было #{nealest_showing.e_B(nealest_showing.starts_at)}"
  end

  def human_price
    humanize_price(showings.map(&:price_min).uniq.compact.min, showings.map(&:price_max).uniq.compact.max)
  end

  def when_with_price
    if showings.any?
      h.content_tag :p, h.content_tag(:span, human_when, :class => :when ) + ", " + h.content_tag(:span, human_price, :class => :price).html_safe
    else
      h.content_tag :p, h.content_tag(:span, human_when, :class => :when )
    end
  end

  def distribution_movie?
    afisha.movie? && afisha_distribution?
  end

  def html_attachments
    return "" if gallery_files.blank?
    links = []
    gallery_files.each do |attachment|
      links << h.content_tag(:li, h.link_to(attachment.description, attachment.file_url))
    end
    h.content_tag :ul, links.join("\n").html_safe
  end

  def viewable_showings?
    #return false if afisha.affiche_schedule
    afisha_actual? && other_showings.any?
  end

  def other_showings
    return [] unless afisha_actual?
    first_showing = showings.first
    @other_showings ||= if first_showing && first_showing.actual?
                          if afisha_distribution?
                            ShowingDecorator.decorate afisha.showings.where("starts_at >= ?", showings.first.starts_at)
                          else
                            ShowingDecorator.decorate afisha.showings.where("starts_at > ?", showings.first.starts_at)
                          end
                        else
                          ShowingDecorator.decorate afisha.showings.where("starts_at > ?", DateTime.now.beginning_of_day)
                        end
  end

  def scheduled_showings?
    afisha.affiche_schedule
  end

  def schedule
    AfficheScheduleDecorator.decorate afisha.affiche_schedule
  end

  def geo_present?
    places.any? && !places.first.latitude.blank? && !places.first.longitude.blank?
  end

  def similar_afisha
    #count = geo_present? ? 3 : 5
    count = 6
    searcher.more_like_this(afisha).limit(count).results.map { |a| AfishaDecorator.new a }
  end

  def searcher
    HasSearcher.searcher(:similar_afisha)
  end

  def kind_searcher(kind, id)
    HasSearcher.searcher(:afishas, :kind => kind, :without => id).actual.paginate(:per_page => 6).results.map { |a| AfishaDecorator.new a }
  end

  auto_html_for :trailer_code do
    youtube(:width => 240, :height => 146)
    vimeo(:width => 240, :height => 146)
    link :target => '_blank'
    double_enter
    simple_format
  end

  def distribution_movie_grouped_showings
    {}.tap do |hash|
      showings.group_by(&:starts_on).each do |date, showings|
        hash[date] = showings.select(&:actual?).group_by(&:place)
      end
    end
  end

  # for popular api
  def resized_image_url(url, width, height, options = { :crop => '!', :magnify => 'm', :orientation => 'n' })
    return if url.blank?
    if url.match(/\d+\/region\/\d+/)
      return url.gsub(/(\/files\/\d+\/region\/(\d+|\/){8})/) { "#{$1}#{width}-#{height}/" }
    end
    if url.match(/\/files\/\d+\/\d+-\d+\//)
      image_url, image_id, image_width, image_height, image_crop, image_filename = url.match(%r{(.*)/files/(\d+)/(?:(\d+)-(\d+)(\!)?/)?(.*)})[1..-1]
      return "#{image_url}/files/#{image_id}/#{width}-#{height}#{options[:crop]}#{options[:magnify]}#{options[:orientation]}/#{image_filename}"
    end
    url
  end

  def event_label
    h.content_tag(:span, '', :class => 'event_label facebook') if /facebook/.match(vk_event_url)
    h.content_tag(:span, '', :class => 'event_label vk') if /vk/.match(vk_event_url)
  end

  def highlighted?
    promoted_at? && (promoted_at + 1.day > Time.zone.now)
  end

  def afisha_title
    title = if afisha.title.present?
              if afisha.showings.any?
                afisha.title.gsub('<period>', I18n.l(afisha.showings.first.starts_on, :format => '%e %B %Y').squish).text_gilensize + ', '
              else
                afisha.title.text_gilensize + ', '
              end
            else
              'Нет названия, '
            end
    title + afisha.kind.map(&:text).join(', ') + " в " + current_city_inclination
  end
end
