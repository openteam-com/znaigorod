# encoding: utf-8

class AfficheDecorator < ApplicationDecorator
  include AutoHtmlFor
  decorates :affiche

  delegate :distribution_starts_on, :distribution_ends_on, :distribution_starts_on?, :distribution_ends_on?, :to => :affiche
  attr_accessor :showings

  def initialize(affiche, showings = nil)
    super
    @showings = showings ? ShowingDecorator.decorate(showings) : ShowingDecorator.decorate(affiche.showings.actual)
  end

  def main_page_link
    truncated_link(45)
  end

  def kind
    affiche.class.name.downcase
  end

  auto_html_for :trailer_code do
    youtube(:width => 740, :height => 450)
  end

  def kind_affiche_path(options = {})
    h.send "#{kind}_path", affiche, options
  end

  def kind_affiche_url(options = {})
    h.send "#{kind}_url", affiche, options
  end

  def kind_affiche_photogallery_path(options = {})
    h.send "#{kind}_photogallery_path", affiche, options
  end

  def kind_affiche_trailer_path(options = {})
    h.send "#{kind}_trailer_path", affiche, options
  end

  def all_affiches_link
    h.link_to "Все #{human_kind.mb_chars.downcase} (#{counter.all})",
              h.affiches_path(kind: kind.pluralize, period: :all)
  end

  def breadcrumbs
    links = []
    links << h.content_tag(:li, h.link_to("Знай\u00ADГород", h.root_path), :class => "crumb")
    links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")
    links << h.content_tag(:li, h.link_to("Вся афиша", h.affiches_path(kind: "affiches", period: :all)), :class => "crumb")
    links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")
    links << h.content_tag(:li, h.link_to("Все #{human_kind.mb_chars.downcase}", h.affiches_path(kind: kind.pluralize, period: :all)), :class => "crumb")
    links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")
    links << h.content_tag(:li, h.link_to(title, kind_affiche_path), :class => "crumb")
    h.content_tag :ul, links.join("\n").html_safe, :class => "breadcrumbs"
  end

  def link
    h.link_to affiche.title.text_gilensize, kind_affiche_path
  end

  def more_link
    h.link_to "Подробнее...", kind_affiche_path, :title => affiche.title
  end

  def schedule
    AfficheScheduleDecorator.decorate affiche.affiche_schedule
  end

  def has_show?
    true
  end

  def has_photogallery?
    affiche.has_images?
  end

  def has_trailer?
    affiche.trailer_code?
  end

  def navigation
    links = []
    %w(show photogallery trailer).each do |method|
      title =
        case method
        when 'show'
          "Описание"
        when 'photogallery'
          affiche.is_a?(Movie) ? "Кадры" : "Фотографии"
        when 'trailer'
          affiche.is_a?(Movie) ? "Трейлер" : "Видео"
        end
      links << Link.new(
                        title: title,
                        url: method == 'show' ? self.send("kind_affiche_path") : self.send("kind_affiche_#{method}_path"),
                        current: h.controller.action_name == method,
                        disabled: !self.send("has_#{method}?"),
                        kind: method
                       )
    end
    current_index = links.index { |link| link.current? }
    return links unless current_index
    links[current_index - 1].html_options[:class] += ' before_current' if current_index > 0
    links[current_index].html_options[:class] += ' current'
    links
  end

  def main_page_place
    max_lenght = 45
    place_output = ""
    places.each_with_index do |place, index|
      place_title = place.organization ? place.organization.title : place.title
      place_link_title = place_title.dup
      place_title = place_title.gsub(/,.*/, '')
      place_title = place_title.truncate(max_lenght, :separator => ' ')
      max_lenght -= place_title.size
      if place.organization
        place_output += h.link_to place_title.text_gilensize.hyphenate, h.organization_path(place.organization), :title => place_link_title.text_gilensize
      else
        place_output += place_link_title.blank? ? place_title.text_gilensize.hyphenate : h.content_tag(:abbr, place_title.text_gilensize.hyphenate, :title => place_link_title.text_gilensize)
      end
      break if max_lenght < 3
      place_output += ", " if index < places.size - 1
    end
    h.raw place_output
  end

  def places
    [].tap do |array|
      showings.map { |showing| showing.organization ? showing.organization : showing.place }.uniq.each do |place|
        array << (place.is_a?(Organization) ? PlaceDecorator.new(:organization => place) : PlaceDecorator.new(:title => place,
                                                                                                              :latitude => affiche.showings.where(:place => place).first.latitude,
                                                                                                              :longitude => affiche.showings.where(:place => place).first.longitude))
      end
    end
  end

  def truncated_description
    description.excerpt.hyphenate
  end

  def html_attachments
    return "" if attachments.blank?
    links = []
    attachments.each do |attachment|
      links << h.content_tag(:li, h.link_to(attachment.description, attachment.url))
    end
    h.content_tag :ul, links.join("\n").html_safe
  end

  def main_page_poster
    poster_with_link affiche, 200, 268
  end

  def posters_list_poster
    poster_with_link affiche, 170, 228
  end

  def tags_for_vk
    desc = ""
    desc << when_with_price
    desc << " "
    desc << main_page_place
    desc << ". "
    desc << html_description
    desc = desc.gsub(/<table>.*<\/table>/m, '').gsub(/<\/?\w+.*?>/m, '').gsub(' ,', ',').squish.html_safe
    image = resized_image_url(poster_url, 180, 242, false)
    res = ""
    res << "<meta name='description' content='#{desc}' />\n"
    res << "<meta property='og:description' content='#{desc.truncate(350, :separator => ' ').html_safe}'/>\n"
    res << "<meta property='og:site_name' content='#{I18n.t('site_title')}' />\n"
    res << "<meta property='og:title' content='#{title.text_gilensize}' />\n"
    res << "<meta property='og:url' content='#{kind_affiche_url}' />\n"
    res << "<meta property='og:image' content='#{image}' />\n"
    res << "<meta name='image' content='#{image}' />\n"
    res << "<link rel='image_src' href='#{image}' />\n"
    res.html_safe
  end

  def raw_places
    showings.with_organization.map(&:organization).uniq.map(&:title).map { |t| t.split(',').join(' ') }
  end

  def keywords_content
    [human_kind, affiche.tags, raw_places].flatten.map(&:mb_chars).map(&:downcase).join(',')
  end

  def meta_keywords
    h.tag(:meta, name: 'keywords', content: keywords_content)
  end

  def list_poster
    poster_with_link affiche, 180, 242
  end

  def item_poster
    h.link_to poster(affiche, 180, 242), affiche.poster_url
  end

  def more_like_this_poster
    poster_with_link affiche, 150, 202
  end

  def affiche_distribution?
    affiche.distribution_starts_on?
  end

  def human_when
    if showings.any?
       if affiche.constant?
         case affiche.class
         when Exhibition
           return "Постоянная экспозиция"
         else
           return "Постоянное мероприятие"
         end
    end
      return human_distribution if affiche.distribution_starts_on?
      return showings.first.human_when
    else
      last_showing = ShowingDecorator.new(affiche.showings.last)
      return "Время проведения неизвестно" unless last_showing.showing
      case affiche.class.name
      when 'Movie'
        if affiche_distribution?
          return human_distribution if affiche.distribution_starts_on >= Date.today
          return "Было в прокате до #{last_showing.e_B(last_showing.starts_at)}"
        else
          return "Последний показ был #{last_showing.e_B(last_showing.starts_at)}"
        end
      when 'Exhibition'
        return "Выставка закончилась #{last_showing.e_B(last_showing.starts_at)}"
      else
        return "Было #{last_showing.e_B(last_showing.starts_at)}"
      end
    end
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

  def human_distribution
    return nil unless distribution_starts_on?
    if distribution_starts_on? && distribution_ends_on?
      return "С #{distribution_starts_on.day} по #{I18n.l(distribution_ends_on, :format => '%e %B')}".squish if  distribution_starts_on.month == distribution_ends_on.month
      return "С #{I18n.l(distribution_starts_on, :format => '%e %B')} по #{I18n.l(distribution_ends_on, :format => '%e %B')}".squish
    end
    return "С #{I18n.l(distribution_starts_on, :format => '%e %B')}".squish
  end

  def kind
    affiche.class.name.downcase
  end

  def pluralized_kind
    kind.pluralize
  end

  def human_kind
    I18n.t("activerecord.models.#{kind}")
  end

  def other_showings
    return [] if affiche.is_a?(Movie)
    if affiche_distribution?
      return affiche.showings.where("starts_at >= ?", showings.first.starts_at) unless showings.blank?
    else
      return affiche.showings.where("starts_at > ?", showings.first.starts_at) unless showings.blank?
    end
    []
  end

  def first_other_showing_today?
    ShowingDecorator.decorate(other_showings.first).today?
  end

  def other_showings_size
    other_showings.count - 2
  end

  def html_many_other_showings
    h.link_to("и еще #{other_showings_size}", kind_affiche_path(:anchor => "showings")) if other_showings_size > 0
  end

  def html_other_showings
    ((ShowingDecorator.decorate(other_showings[0..1]).map(&:html_other_showing)).compact.join(", <br />") + "&nbsp;" + html_many_other_showings.to_s).html_safe
  end

  def distribution_movie?
    affiche.is_a?(Movie) && affiche_distribution?
  end

  def distribution_movie_nearlest_grouped_showings
    showings.any? ? showings.group_by(&:starts_on).first.second.select(&:actual?).group_by(&:place) : []
  end

  def distribution_movie_grouped_showings
    {}.tap do |hash|
      showings.group_by(&:starts_on).each do |date, showings|
        hash[date] = showings.select(&:actual?).group_by(&:place)
      end
    end
  end

  def distribution_movie_schedule_date
    "Ближайшие сеансы #{showings.first.human_date.mb_chars.downcase}" if showings.any?
  end

  def similar_affiches
    searcher.more_like_this(affiche).limit(2).results.map { |a| AfficheDecorator.new a }
  end

  def similar_affiches_with_images
    searcher.more_like_this(affiche).with_images.limit(2).results.map { |a| AfficheDecorator.new a }
  end

  def trailer
    return "" if trailer_code.blank?
    trailer_code.html_safe
  end

  def scheduled_showings?
    !affiche.affiche_schedule.nil? && affiche.is_a?(Exhibition)
  end

  private

  def truncated_link(length, anchor = nil)
    h.link_to affiche.title.text_gilensize.truncated(length), kind_affiche_path(anchor: anchor), :title => affiche.title
  end

  def in_one_day?
    distribution_starts_on == distribution_ends_on
  end

  def poster_with_link(affiche, width, height)
    h.link_to poster(affiche, width, height), kind_affiche_path
  end

  def poster(affiche, width, height)
    image_tag(affiche.poster_url, width, height, affiche.title.text_gilensize)
  end

  def searcher
    HasSearcher.searcher(:similar_affiches)
  end

  def counter
    Counter.new(:kind => kind)
  end
end
