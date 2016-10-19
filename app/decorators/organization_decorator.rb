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
    arr.join('; ').html_safe
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
    if email.present?
      content = []
      email.squish.split(',').map(&:strip).each do |e|
        content << h.mail_to(e)
      end
      content.join(', ').html_safe
    end
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
    return h.content_tag(:div, "Гибкий график работы", :class => "schedule_wrapper work_schedule") if full_schedules.empty?

    week_day = Time.zone.today.strftime("%A").downcase
    schedule = organization.get_full_schedule_by_day(week_day)
    if !schedule.free
      if schedule.from != schedule.to && !organization.work_all_day?
        content = "<span class='ul-toggler js-ul-toggler'>#{schedule_time(schedule.from, schedule.to)}</span>".html_safe
      elsif organization.work_all_day?
        content = "Работает ежедевно <span class='ul-toggler js-ul-toggler'>#{schedule_time(schedule.from, schedule.to)}</span>".html_safe
      else
        content = "<span class='ul-toggler js-ul-toggler'>круглосуточно</span>".html_safe
      end
    else
      content = "Сегодня <span class='ul-toggler js-ul-toggler'>выходной</span>".html_safe
    end
    content
  end

  def work_schedule
    work_full_schedule
  end

  def work_full_schedule
    return h.content_tag(:div, "Гибкий график работы", :class => "schedule_wrapper work_schedule") if full_schedules.empty?

    week_day = Time.zone.today.strftime("%A").downcase
    schedule = organization.get_full_schedule_by_day(week_day)
    if !schedule.free
      if schedule.from != schedule.to && !organization.work_all_day?
        content = "<span class='ul-toggler js-ul-toggler'>#{schedule_time(schedule.from, schedule.to)}</span>".html_safe
      elsif organization.work_all_day?
        content = "Работает ежедевно <span class='ul-toggler js-ul-toggler'>#{schedule_time(schedule.from, schedule.to)}</span>".html_safe
      else
        content = "<span class='ul-toggler js-ul-toggler'>круглосуточно</span>".html_safe
      end
    else
      content = "Сегодня <span class='ul-toggler js-ul-toggler'>выходной</span>".html_safe
    end
    more_schedule = ""
    full_schedules.where(:free => false).each do |sch|
      more_schedule << h.content_tag(:li, "<span class='days'>#{sch.get_mode}</span>".html_safe)
    end
    full_schedules.where(:free => true).each do |sch|
      more_schedule << h.content_tag(:li, "<span class='days'>#{sch.get_mode}</span>".html_safe)
    end
    more_schedule = h.content_tag(:ul, more_schedule.html_safe, class: 'js-ul-toggleable ul-toggleable')
    h.content_tag(:div, "Время работы: #{content}".html_safe, :class => "schedule_wrapper work_schedule #{open_closed(schedule.from, schedule.to)}") + more_schedule
  end

  # FIXME: mabe not used
  def schedule_content
    more_schedule = ""
    full_schedules.where(:free => false).each do |sch|
      more_schedule << h.content_tag(:li, "<div class='string'>#{sch.get_mode}</div>".html_safe)
    end
    full_schedules.where(:free => true).each do |sch|
      more_schedule << h.content_tag(:li, "<div class='string'>#{sch.get_mode}</div>".html_safe)
    end
    h.content_tag(:ul, more_schedule.html_safe, class: :schedule)
  end

  def schedule_today
    week_day = Time.zone.today.strftime("%A").downcase
    schedule = organization.get_full_schedule_by_day(week_day)
    if !schedule.free
      if schedule.from != schedule.to && !organization.work_all_day?
        content = "#{schedule_time(schedule.from, schedule.to)}".html_safe
      elsif organization.work_all_day?
        content = "Работает ежедевно #{schedule_time(schedule.from, schedule.to)}"
      else
        content = "круглосуточно"
      end
    else
      content = "Сегодня выходной"
    end
    h.content_tag(:div, content, class: schedule.free ? 'schedule_today closed' : 'schedule_today opened') unless content.blank?
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
