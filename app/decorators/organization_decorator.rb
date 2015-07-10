#encoding: utf-8

class OrganizationDecorator < ApplicationDecorator
  decorates :organization

  include OpenGraphMeta

  delegate :decorated_phones, :to => :decorated_priority_suborganization

  def title
    organization.title.text_gilensize
  end

  def truncated_title_link(width = 28)
    if organization.title.length > width
      h.link_to h.truncate(organization.title, length: width).text_gilensize, organization_url, title: title
    else
      h.link_to title, organization_url
    end
  end

  def logotype_link(width = 178, height = 178)
    @logotype_link ||= h.link_to(
      h.image_tag(h.resized_image_url(organization.logotype_url, width, height), size: "#{width}x#{height}", alt: title),
      organization_url) if organization.logotype_url?
  end

  def truncated_address_link(need_city = true)
    return "" if address.to_s.blank?
    address = organization.address
    city = need_city ? address.city : ''
    return h.link_to "#{city} #{address}#{office}".truncated(28, nil),
        organization_url,
        :title => 'Показать на карте',
        :'data-latitude' => organization.address.latitude,
        :'data-longitude' => organization.address.longitude,
        :'data-hint' => organization.title.text_gilensize,
        :'data-id' => organization.id,
        :class => 'show_map_link' if address.latitude? && address.longitude?
    "#{address}#{office}".truncated(28, nil)
  end

  def address_link(address = organization.address)
    arr = []
    ([address] + organization.slave_organizations.map(&:address)).compact.each do |address|
      arr << "" if address.to_s.blank?
      if address.latitude? && address.longitude?
      arr << h.link_to("#{address.city}, #{address}#{office}",
        organization_url,
        :title => 'Показать на карте',
        :'data-latitude' => address.latitude,
        :'data-longitude' => address.longitude,
        :'data-hint' => organization.title.text_gilensize,
        :'data-id' => organization.id,
        :class => 'show_map_link')
      else
        arr << "#{address}#{office}"
      end
    end
    arr.join('; ')
  end

  def address_without_link(address = organization.address)
    return "" if address.to_s.blank?
    return h.content_tag :span, "#{address}#{office}",
      :title => "#{address.office}"
  end

  def office
    return ", #{organization.address.office.squish}" unless organization.address.office.blank?
  end

  def show_url
    organization_url
  end

  def organization_url
    h.organization_url(organization)
  end

  def email_link
    h.mail_to email.squish unless email.blank?
  end

  def site_link
    h.link_to site.squish, AwayLink.to(site.squish), rel: "nofollow", target: "_blank" unless site.blank?
  end

  def contact_links
    content = ''
    content << site_link.to_s
    content << ', ' if content.present? && email_link.present?
    content << email_link.to_s

    content.html_safe
  end

  def decorated_phones
    return h.content_tag :div, "&nbsp;".html_safe, class: 'phone' if phone.blank?
    phones = phone.squish.split(', ')
    return h.content_tag :div, phones.first, class: 'phone' if phones.one?
    return h.content_tag :div, "#{phones.first}&hellip;".html_safe, class: 'phone many', title: phones.join(', ') if phones.many?
  end

  # FIXME: грязный хак ;(
  def fake_kind
    %w[billiard].include?(priority_suborganization_kind) ? 'entertainment' : priority_suborganization_kind
  end

  # FIXME: грязный хак ;(
  def fake_class(suborganization)
    [Billiard].include?(suborganization.class) ? Entertainment : suborganization.class
  end

  def breadcrumbs
    links = []
    links << h.content_tag(:li, h.link_to("Знай\u00ADГород", h.root_path), :class => "crumb")
    links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")

    links << h.content_tag(:li, h.link_to(I18n.t("organization.list_title.#{fake_kind}") + " Томска ", h.send("#{fake_kind.pluralize}_path"), :class => "crumb"))
    links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")

    if priority_category != I18n.t("organization.list_title.#{fake_kind}") && !%w(car_sales_center).include?(fake_kind)
      links << h.content_tag(:li, link_to_priority_category, :class => "crumb")
      links << h.content_tag(:li, h.content_tag(:span, "&nbsp;".html_safe), :class => "separator")
    end

    links << h.content_tag(:li, h.link_to(title, organization_url), :class => "crumb")

    h.content_tag :ul, links.join("\n").html_safe, :class => "breadcrumbs"
  end

  def suborganizations
    @suborganizations ||= (Organization.available_suborganization_kinds).map { |kind| organization.send(kind) }.compact.uniq
  end

  def decorated_suborganizations
    return [] if suborganizations.compact.blank?
    suborganizations.map { |suborganization| "#{suborganization.class.name.underscore}_decorator".classify.constantize.decorate suborganization }
  end

  def decorated_priority_suborganization
    @decorated_priority_suborganization ||= "#{priority_suborganization_kind}_decorator".classify.constantize.decorate priority_suborganization
  end

  def categories
    return [] if suborganizations.compact.blank?
    suborganizations.each.map(&:categories).flatten
  end

  def priority_category
    priority_suborganization.categories.first || ''
  end

  def work_schedule_for_list_view
    return "Гибкий график работы" if schedules.empty?
    from = schedules.pluck(:from).uniq
    to   = schedules.pluck(:to).uniq
    week_day = Time.zone.today.cwday
    content = week_day
    schedule = organization.schedules.find_by_day(week_day)
    content = if from.size == to.size && from.size == 1
                if from[0].blank? && to[0].nil?
                  content = 'Гибкий график работы'
                elsif from == to
                  content = 'Работает круглосуточно'
                else
                  content = "Работает ежедневно #{schedule_time(from[0], to[0])}"
                end
              else
                content = "Сегодня #{schedule_time(schedule.from, schedule.to)}"
              end
  end

  def work_schedule
    return h.content_tag(:div, "Гибкий график работы", :class => "schedule_wrapper work_schedule") if schedules.empty?
    content = ''
    more_schedule = ''
    from = schedules.pluck(:from).uniq
    to   = schedules.pluck(:to).uniq
    week_day = Time.zone.today.cwday
    content = week_day
    schedule = organization.schedules.find_by_day(week_day)
    if from.size == to.size && from.size == 1
      if from[0].blank? && to[0].nil?
        content = 'Гибкий график работы'
      elsif from == to
        content = 'Работает круглосуточно'
      else
        content = "Работает ежедневно #{schedule_time(from[0], to[0])}"
      end
    else
      content = "Сегодня <span class='ul-toggler js-ul-toggler'>#{schedule_time(schedule.from, schedule.to)}</span>".html_safe
      hash_schedule = {}
      schedules.each do |schedule|
        daily_schedule = schedule_time(schedule.from, schedule.to)
        hash_schedule[daily_schedule] ||= []
        hash_schedule[daily_schedule] << schedule.day
      end
      more_schedule = ""
      hash_schedule.each do |daily_scheule, days|
        more_schedule << h.content_tag(:li, "<span class='days'>#{schedule_day_names(days)}:</span> <span class='hours'>#{daily_scheule}</span>".html_safe)
      end
      more_schedule = h.content_tag(:ul, more_schedule.html_safe, class: 'js-ul-toggleable ul-toggleable')
    end
    h.content_tag(:div, "Время работы: #{content}".html_safe, :class => "schedule_wrapper work_schedule #{open_closed(schedule.from, schedule.to)}") + more_schedule
  end

  # FIXME: mabe not used
  def schedule_content
    content = ""
    schedules.each do |schedule|
      day = h.content_tag(:div, schedule.short_human_day, class: :dow)
      schedule_content = if schedule.holiday?
        h.content_tag(:div, "Выходной", class: :string)
      elsif schedule.from == schedule.to
        h.content_tag(:div, "Круглосуточно", class: :string)
      else
        (h.content_tag(:div, I18n.l(schedule.from, :format => "%H:%M"), class: :from) + h.content_tag(:div, I18n.l(schedule.to, :format => "%H:%M"), class: :to)).html_safe
      end
      content << h.content_tag(:li, (day + schedule_content).html_safe, class: I18n.l(Date.today, :format => '%a') == schedule.short_human_day ? 'today' : nil)
    end
    h.content_tag(:ul, content.html_safe, class: :schedule)
  end

  def schedule_today
    klass = "schedule_today "
    if schedules.any?
      from = schedules.pluck(:from).uniq
      to   = schedules.pluck(:to).uniq
      if from.size == to.size && from.size == 1
        if from[0].blank? && to[0].nil?
          content = 'Гибкий график работы'
        elsif from == to
          content = 'Работает круглосуточно'
        else
          content = "Работает ежедневно #{schedule_time(from[0], to[0])}"
        end
      else
        content = "Сегодня "
        wday = Time.zone.today.wday
        wday = 7 if wday == 0
        schedule = organization.schedules.find_by_day(wday)
        if schedule.holiday?
          content << "выходной"
          klass << "closed"
        elsif schedule.from == schedule.to
          content << "работает круглосуточно"
          klass << "twenty_four"
        else
          content << "работает #{schedule_time(schedule.from, schedule.to)}"
          now = Time.zone.now
          time = Time.utc(2000, "jan", 1, now.hour, now.min)
          from = schedule.from
          to = schedule.to
          to = to + 1.day if to.hour < 12
          if time.between?(from, to)
            klass << "opened"
          else
            klass << "closed"
          end
        end
      end
    else
      content = "График работы неизвестен"
      klass << "closed"
    end
    h.content_tag(:div, content, class: klass) unless content.blank?
  end

  def link_to_priority_category
    h.link_to(priority_category + " Томска ", h.send("#{fake_kind.pluralize}_path", categories: [priority_category.mb_chars.downcase]))
  end

  def category_links
    organization_categories.map do |category|
      Link.new :title => category.title, :url => h.send("organizations_by_category_path", category.slug)
    end
  end

  def has_photogallery?
    organization.gallery_images.any?
  end

  def has_tour?
    organization.virtual_tour.link?
  end

  def has_affiche?
    actual_affiches_count > 0
  end

  def has_show?
    true
  end

  def stand_info
    res = ""
    if organization_stand && !organization_stand.places.to_i.zero?
      res << I18n.t("organization_stand.places", count: organization_stand.places)
      organization_stand.guarded? ? res << ", охраняется" : res << ", не охраняется"
      organization_stand.video_observation? ? res << ", есть видеонаблюдение" : res << ", без видеонаблюдения"
    end
    res
  end

  def navigation
    links = []
    %w(show photogallery tour affiche).each do |method|
      links << Link.new(
                        title: I18n.t("organization.#{method}"),
                        url: h.send(method == 'show' ? "organization_path" : "#{method}_organization_path"),
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

  # overrides OpenGraphMeta.meta_keywords
  def meta_keywords
    keywords = categories
    suborganizations.each do |suborganization|
      %w[features offers cuisines].each do |field|
        keywords += suborganization.send(field) if suborganization.respond_to?(field) && suborganization.send(field).any?
      end
    end
    keywords.map(&:mb_chars).map(&:downcase).join(', ')
  end

  def actual_affiches_count
    HasSearcher.searcher(:showings, organization_ids: [organization.id]).actual.order_by_starts_at.groups.group(:affiche_id_str).total
  end

  def truncated_description
    description.excerpt
  end

  def iconize_info
    content = ''
    if non_cash?
      text = h.content_tag(:span, 'безналичный расчет', class: 'non_cash', title: 'безналичный расчет')
      content << h.content_tag(:li, "#{text}".html_safe)
    end
    h.content_tag :ul, content.html_safe, class: :iconize_info if content.present?
  end

  # FIXME: может быть как-то можно использовать config/initializers/searchers.rb
  # но пока фиг знает как ;(
  def raw_similar_organizations
    lat, lon = organization.latitude, organization.longitude
    radius = 3
    return [] if priority_suborganization.blank?

    search = priority_suborganization.class.search do
      with(:location).in_radius(lat, lon, radius) if lat.present? && lon.present?
      without(priority_suborganization)

      order_by_geodist(:location, lat, lon) if lat.present? && lon.present?
      with(:status, [:client, :client_economy, :client_standart, :client_premium])
      paginate(page: 1, per_page: 5)
    end

    search.results.map(&:organization)
  end

  def similar_organizations
    OrganizationDecorator.decorate raw_similar_organizations
  end
end
