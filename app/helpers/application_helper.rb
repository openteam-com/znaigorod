# encoding: utf-8

module ApplicationHelper
  def auto_content_class
    name_with_action = "#{controller_name}_#{action_name}"

    controller_name == controller_path ?
      name_with_action :
      "#{controller_path.split('/').join('_')}_#{action_name} #{name_with_action}"
  end

  def price_for(showing)
    return 'бесплатно' if showing.price_min.zero? && showing.price_max.zero?
    return number_to_currency(showing.price_min, :precision => 0) if showing.price_max.zero?

    "#{showing.price_min} &mdash; #{number_to_currency(showing.price_max, :precision => 0)}".html_safe
  end

  def transliterate(string)
    I18n.transliterate(string).downcase.gsub(/[^[:alnum:]]+/,'_')
  end

  def interval_for(showing)
    since_date, since_time = l(showing.starts_at.to_datetime, :format => '%d.%B.%Y %H:%M').split(' ')
    until_date, until_time = l(showing.ends_at.to_datetime, :format => '%d.%B.%Y %H:%M').split(' ') if showing.ends_at

    since_date.gsub!('.', ' ')
    until_date.gsub!('.', ' ') if showing.ends_at

    since_arr = []
    until_arr = []

    since_arr << content_tag(:span, since_date, :class => 'nobr')
    until_arr << content_tag(:span, until_date, :class => 'nobr') if since_date != until_date && !until_date.nil?

    if since_time != '00:00'
      since_arr << ", #{since_time}"
      if until_time != '00:00' && until_time != '23:59' && !until_time.nil?
        if since_time != until_time
          if until_arr.empty?
            until_arr << until_time
          else
            until_arr << ", #{until_time}"
          end
        else
          unless until_arr.empty?
            until_arr << ", #{until_time}"
          end
        end
      end
    else
      if until_time != '00:00' && until_time != '23:59' && !until_time.nil?
        unless until_arr.empty?
          until_arr << ", #{until_time}"
        end
      end
    end

    res = since_arr.join

    unless until_arr.empty?
      res += ' &ndash; '
      res += until_arr.join
    end

    res.html_safe
  end

  def is_active_filter?(filter_name)
    return params.has_key?('search') && params['search'][filter_name].try(:any?) ? true : false
  end

  def is_active_variant?(filter, variant)
    if is_active_filter?(filter) == true
      params['search'][filter].include?(variant) ? 'active' : ''
    else
      false
    end
  end

  def stale_at(date)
    if date.hour == 0
      I18n.l(date, :format => '%e %B %Y')
    else
      I18n.l(date, :format => '%e %B %Y года в %H:%M')
    end
  end

  def current_city_inclination
    Settings['app.city'] == 'tomsk' ? 'Томске' : 'Севастополе'
  end

  def days_to_new_year
    Time.zone.now.end_of_year.yday - Time.zone.now.yday
  end
end
