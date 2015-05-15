# encoding: utf-8

class ShowingDecorator < ApplicationDecorator
  decorates :showing

  delegate :starts_at, :ends_at, :ends_at?, :to => :showing

  def human_date
    today? ? 'Сегодня' : e_B(starts_at)
  end

  def human_when
    unless ends_at?
      date = human_date
      date += " в #{H_M(starts_at)}" unless starts_at_only_date?

      return date
    else
      from_time = starts_at_only_date? ? '' : H_M(starts_at)
      to_time = ends_at_only_date? ? '' : H_M(ends_at)

      if in_one_day?
        if starts_at == ends_at
          date = 'Круглосуточно'
        else
          date = today? ? 'Сегодня' : e_B(starts_at)
          date += " с #{from_time}" unless starts_at_only_date?
          date += " до #{to_time}" unless ends_at_only_date?

        end
        return date
      else
        return "#{starts_at.day} &ndash; #{e_B(ends_at)}".html_safe if in_one_month? && starts_at_only_date? && ends_at_only_date?
        return "#{e_B(starts_at)} &ndash; #{e_B(ends_at)}".html_safe if starts_at_only_date? && ends_at_only_date?
        return "#{e_m(starts_at)}, #{from_time} &ndash; #{e_m(ends_at)}, #{to_time}".html_safe
      end
    end
  end

  def human_when_time
    unless ends_at?
      date = "#{H_M(starts_at)}" unless starts_at_only_date?
      return date
    else
      from_time = starts_at_only_date? ? '' : H_M(starts_at)
      to_time = ends_at_only_date? ? '' : H_M(ends_at)
      date = "#{from_time}" unless starts_at_only_date?
      date += " &ndash; #{to_time}" unless ends_at_only_date?
      return date
    end
  end

  def human_time_starts_at
    H_M(showing.starts_at)
  end

  def place_decorator
    return PlaceDecorator.new(:organization => showing.organization) if showing.organization
    PlaceDecorator.new(:title => showing.place, :latitude => showing.latitude, :longitude => showing.longitude)
  end

  def human_price
    humanize_price(showing.price_min, showing.price_max)
  end

  def html_other_showing
    h.content_tag(:strong, human_when) + " (#{human_price})".html_safe
  end

  def today?
    starts_at >= Time.zone.now.beginning_of_day && starts_at <= Time.zone.now.end_of_day
  end

  def in_one_month?
    starts_at.month == ends_at.month
  end

  def in_one_day?
    starts_at.to_date == ends_at.to_date
  end

  def starts_at_only_date?
    starts_at == starts_at.beginning_of_day
  end

  def ends_at_only_date?
    H_M(ends_at) == H_M(ends_at.end_of_day)
  end

  def e(date)
    I18n.l(date, :format => '%e').squish
  end

  def B(date)
    I18n.l(date, :format => '%B')
  end

  def e_B(date)
    I18n.l(date, :format => '%e %B').squish
  end

  def e_m(date)
    I18n.l(date, :format => '%e.%m').squish
  end

  def H_M(date)
    I18n.l(date, :format => '%H:%M')
  end

  def day_name(date)
    I18n.l(date, :format => '%A').mb_chars.downcase
  end

  def for_schedule
    ''.tap do |html|
      date = h.content_tag :p, class: 'date' do
        day, month = e_B(starts_at).split(" ")
        date = ''
        date << h.content_tag(:span, day, :class => 'day')
        date << h.content_tag(:span, month, :class => 'month')
        date << h.content_tag(:span, day_name(starts_at), :class => 'day_of_week')
        date.html_safe
      end
      html << date
      html << h.content_tag(:p, human_when_time.html_safe, class: 'time') if starts_at.beginning_of_day != starts_at
      html << h.content_tag(:p, human_price, :class => 'price') unless human_price.blank?
    end.html_safe
  end
end
