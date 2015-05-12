# encoding: utf-8

class DiscountDecorator < ApplicationDecorator
  decorates :discount

  include OpenGraphMeta

  # overrides OpenGraphMeta.object_url
  def object_url
    h.discount_url(model)
  end

  def goes_now?
    starts_at < Time.zone.now && ends_at > Time.zone.now
  end

  def will_goes?
    starts_at > Time.zone.now
  end

  def countdown_time
    if goes_now?
      ends_at.to_i * 1000
    else
      starts_at.to_i * 1000
    end
  end

  def when_with_price
    h.content_tag :p, h.content_tag(:span, human_when, :class => :when)
  end

  def human_info
    if discount.is_a?(OfferedDiscount)
      'Предложение цены'
    elsif sale?
      'Акция'
    else
      "Скидка " + h.content_tag(:span, "#{discount.discount}%", :class => :profit)
    end
  end

  def human_when
    unless actual?
      return "Было: #{I18n.l(ends_at, :format => '%e.%m.%Y')}".squish
    else
      if constant?
        return 'Постоянная скидка'
      else
        if price.nil?
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}".squish
        elsif price.zero?
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, бесплатно".squish
        elsif price < 0
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, цена неизвестна".squish
        else
          return "Действует: #{I18n.l(starts_at, :format => '%e.%m')} - #{I18n.l(ends_at, :format => '%e.%m.%Y')}, #{h.number_to_currency(price, :unit => 'р.', :precision => 0)}".squish
        end
      end
    end
  end

  def human_place
    results = ''
    places.each do |place|
      if place.organization_id?
        results += PlaceDecorator.new(:organization => place.organization).place
      else
        results += PlaceDecorator.new(:latitude => place.latitude, :longitude => place.longitude, :title => place.address).place
      end
    end

    h.raw results
  end

  def place_without_map
    results = ''

    return results if places.empty?

    place = places.first

    if place.organization_id?
      results += h.link_to h.truncate(place.organization.try(:title), :length => 30), place.organization, :title => place.address
    else
      results += h.truncate(place.address, :length => 30)
    end

    h.raw results
  end

  def geo_present?
    places.any? && !places.first.latitude.blank? && !places.first.longitude.blank?
  end

  def similar_discount
    HasSearcher.searcher(:similar_discount).more_like_this(discount).limit(6).results.map { |d| DiscountDecorator.new d } if discount.published?
    kind_discounts(discount.kind.first) if discount.archive?
  end

  def kind_discounts(kind)
    HasSearcher.searcher(:discounts, :kind => kind).paginate(:per_page => 6).without_archive.results.map { |d| DiscountDecorator.new d }
  end

  def type_discounts(type)
    HasSearcher.searcher(:discounts, :type => type).paginate(:per_page => 6).results.map { |d| DiscountDecorator.new d }
  end

  def smart_path(options = {})
    if discount.is_a?(OfferedDiscount) && discount.organizations.any?
      h.organization_path discount.organizations.first, options
    else
      h.discount_path discount, options
    end
  end

  def to_partial_path
    'discounts/discount_poster'
  end

  def highlighted?
    promoted_at? && (promoted_at + 1.day > Time.zone.now)
  end
end
