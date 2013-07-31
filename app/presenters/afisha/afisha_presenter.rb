# encoding: utf-8

require 'afisha_presenter_filter'

class AfishaPresenter
  include ActiveAttr::MassAssignment

  attr_accessor :categories,
                :period,
                :price_min, :price_max,
                :age_min, :age_max,
                :time_from, :time_to,
                :organization_ids,
                :tags,
                :lat, :lon, :radius,
                :order_by,
                :page, :per_page,
                :view,
                :hide_categories

  def initialize(args)
    super(args)
    self.categories ||= []

    @page     ||= 1
    @per_page   = 12
    @view       = 'posters'

    initialize_filters
  end

  def initialize_filters
    @categories_filter    ||= CategoriesFilter.new(categories, hide_categories)
    @period_filter        ||= PeriodFilter.new(period)
    @price_filter         ||= PriceFilter.new(price_min, price_max)
    @age_filter           ||= AgeFilter.new(age_min, age_max)
    @time_filter          ||= TimeFilter.new(time_from, time_to)
    @organizations_filter ||= OrganizationsFilter.new(organization_ids)
    @tags_filter          ||= TagsFilter.new(tags, @categories_filter.only_category)
    @geo_filter           ||= GeoFilter.new(lat, lon, radius)
  end
  attr_reader :age_filter, :categories_filter, :organizations_filter, :period_filter,
    :price_filter, :tags_filter, :time_filter, :geo_filter

  def self.available_sortings
    %w[rating creation starts_at nearness]
  end

  available_sortings.each do |sorting|
    define_method "sort_by_#{sorting}?" do
      @order_by == sorting
    end
  end

  def available_sortings
    self.class.available_sortings
  end

  def order_by
    @order_by = available_sortings.include?(@order_by) ? @order_by : 'creation'
    @order_by = (available_sortings & [@order_by]).any? ? @order_by : 'creation' if !geo_filter.used?

    @order_by
  end

  def url
    #return 'afisha' unless categories_filter.hidden?
    categories_filter.selected.first.try(:pluralize) || 'afisha'
  end

  def kind
    categories.first || 'all'
  end

  def collection
    searcher.group(:afisha_id_str).groups.map do |group|
      afisha = Afisha.find(group.value)
      showings = group.hits.map(&:result)

      AfishaDecorator.new(afisha, ShowingDecorator.decorate(showings))
    end
  end

  def paginated_collection
    searcher.group(:afisha_id_str).groups
  end

  def total_count
    searcher.group(:afisha_id_str).total
  end

  def view_list?
    view == 'list'
  end

  def partial
    "afishas/afisha_#{view}"
  end

  def categories_links
    @categories_links ||= [].tap { |array|
      array << {
        title: I18n.t('enumerize.afisha.kind.all'),
        parameters: { category: 'afisha', period: period_filter.all? ? nil : period_filter.period },
        current: kind == 'all',
        count: AfishaCounter.new(:period => period_filter.period, :date => period_filter.date).count
      }
      Afisha.kind.values.each do |kind|
        array << {
          title: "#{kind.text}",
          parameters: { category: kind.pluralize, period: period_filter.all? ? nil : period_filter.period },
          current: categories.include?(kind),
          count: AfishaCounter.new(category: kind, :period => period_filter.period, :date => period_filter.date).count
        }
      end
    }
  end

  def keywords
    [].tap { |keywords|
      keywords.concat(categories_filter.human_names) if keywords.empty?
    }.join(', ')
  end

  def page_title
    title = I18n.t("meta.#{url}.title")
    title += " сегодня" if period_filter.period == 'today'
    title += " на этой неделе" if period_filter.period == 'week'
    title += " на выходных" if period_filter.period == 'weekend'
    title += "за #{I18n.l(period_filter.date, format: "%d %B")}" if period_filter.date?
    title
  end

  def meta_description
    I18n.t("meta.#{url}.description", default: I18n.t('meta.default.description'))
  end

  def meta_keywords
    I18n.t("meta.#{url}.keywords", default: I18n.t('meta.default.description'))
  end

  def searcher_params
    @searcher_params ||= {}.tap do |params|
      params[:age_max]          = age_filter.maximum         if age_filter.maximum.present?
      params[:age_min]          = age_filter.minimum         if age_filter.minimum.present?
      params[:afisha_state]    = 'published'
      params[:categories]       = categories_filter.selected if categories_filter.selected.any?
      params[:organization_ids] = organizations_filter.ids   if organizations_filter.ids.any?
      params[:price_max]        = price_filter.maximum       if price_filter.maximum.present?
      params[:price_min]        = price_filter.minimum       if price_filter.minimum.present?
      params[:starts_on]        = period_filter.date         if period_filter.date?
      params[:tags]             = tags_filter.selected       if tags_filter.selected.any?
      params[:from]             = time_filter.from           if time_filter.from.present?
      params[:to]               = time_filter.to             if time_filter.to.present?

      params[:location] = Hashie::Mash.new(lat: geo_filter.lat, lon: geo_filter.lon, radius: geo_filter.radius) if geo_filter.used?
    end
  end

  def query
    searcher_params.dup.tap { |hash|
      hash.delete(:afisha_state)
      hash.delete(:location)
      hash.delete(:starts_on)

      hash[:utf8] = '✓'
      %w[order_by view period lat lon radius].each { |p| hash[p] = send(p) }
    }
  end

  private

  def searcher
    @searcher ||= HasSearcher.searcher(:showings, searcher_params).tap { |s|
      s.paginate(page: page, per_page: per_page)
      s.groups
      s.send("order_by_#{order_by}")

      unless period_filter.date?
        case period_filter.period
        when 'all'
          s.actual
        when 'today'
          s.today.actual
        when 'week'
          s.week.actual
        when 'weekend'
          s.weekend.actual
        end
      end
    }
  end
end
