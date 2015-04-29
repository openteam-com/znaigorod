# OPTIMIZE: after changes needs reboot even in development

class CategoriesFilter
  attr_accessor :selected, :available, :human_names

  def initialize(categories, hidden = false)
    @available   = Afisha.kind.values
    @selected    = (categories || []).delete_if(&:blank?) & @available
    @human_names = Afisha.kind.values.map(&:text)
    @hidden = !!hidden
  end

  def used?
    selected.any?
  end

  def hidden?
    @hidden
  end

  def only_category
    selected.first if hidden?
  end

  def scopes(collection)
    used? ? collection.where('afishas.kind = ?', @selected) : collection
  end
end

class PeriodFilter
  def initialize(period, on)
    @date = on.to_date rescue nil
    @period = period
    @date ||= Date.today if self.daily?
  end

  def date
    @date
  end

  def period
    available_period_values.include?(@period) ? @period : 'all'
  end

  def date?
    !!@date
  end

  def used?
    true
  end

  def self.available_period_values
    %w[na_segodnya na_nedelyu na_vyhodnye daily]
  end

  def available_period_values
    self.class.available_period_values
  end

  available_period_values.each do |name|
    define_method "#{name}?" do
      name == @period
    end
  end

  def all?
    @period == 'all' || @period.nil?
  end

  def scopes(collection)
    actual_collection = collection.where('showings.starts_at > ? OR showings.ends_at > ?',
                       DateTime.now.beginning_of_day,
                       DateTime.now.beginning_of_day)
    case period
    when 'all'
      actual_collection
    when 'na_segodnya'
      actual_collection.where('showings.starts_at < ?', DateTime.now.end_of_day)
    when 'na_nedelyu'
      actual_collection.where('showings.starts_at > ? OR showings.starts_at < ?',
                       DateTime.now.beginning_of_week,
                       DateTime.now.end_of_week).where('showings.ends_at IS NULL OR showings.ends_at < ?',
                                                       DateTime.now.end_of_week)
    when 'na_vyhodnye'
      actual_collection.where('showings.starts_at > ? OR showings.starts_at < ?',
                              DateTime.now.end_of_week - 2.days + 1.second,
                              DateTime.now.end_of_week).where('showings.ends_at IS NULL OR showings.ends_at < ?',
                                                              DateTime.now.end_of_week - 2.days + 1.second)
    else
      actual_collection
    end
  end
end

class SortingFilter
  def initialize(sorting, geo_filter)
    @order_by = sorting
    @geo_filter = geo_filter
  end

  def self.available_sortings_values
    %w[creation rating starts_at nearness]
  end

  def available_sortings_values
    sortings = %w[creation rating starts_at]
    sortings << 'nearness' if @geo_filter.used?
    sortings
  end

  available_sortings_values.each do |sorting|
    define_method "sort_by_#{sorting}?" do
      @order_by == sorting
    end
  end

  def order_by_random?
    @order_by == 'random'
  end

  def order_by
    @order_by = available_sortings_values.include?(@order_by) ? @order_by : 'creation'
    @order_by
  end
end

class PriceFilter
  attr_accessor :minimum, :maximum

  def initialize(minimum, maximum)
    @minimum, @maximum = minimum, maximum
  end

  def available
    Hashie::Mash.new(
      minimum: Afisha.with_showings.joins(:showings).minimum(:price_min),
      maximum: Afisha.with_showings.joins(:showings).maximum(:price_max)
    )
  end

  def selected
    Hashie::Mash.new(
      minimum: minimum.present? ? minimum : available.minimum,
      maximum: maximum.present? ? maximum : available.maximum
    )
  end

  def used?
    minimum.present? || maximum.present?
  end
end

class AgeFilter
  attr_accessor :minimum, :maximum

  def initialize(minimum, maximum)
    @minimum, @maximum = minimum, maximum
  end

  def available
    Hashie::Mash.new(
      minimum: 0, maximum: 99
    )
  end

  def selected
    Hashie::Mash.new(
      minimum: minimum.present? ? minimum : available.minimum,
      maximum: maximum.present? ? maximum : available.maximum
    )
  end

  def used?
    minimum.present? || maximum.present?
  end
end

class TimeFilter
  attr_accessor :from, :to

  def initialize(from, to)
    @from, @to = from, to
  end

  def available
    Hashie::Mash.new(from: 0, to: 23)
  end

  def selected
    Hashie::Mash.new(
      from: from.present? ? from : available.from,
      to:   to.present?   ? to   : available.to
    )
  end

  def used?
    from.present? || to.present?
  end
end

class OrganizationsFilter
  attr_accessor :selected

  def initialize(ids)
    @selected = (ids || []).map(&:to_i)
  end
  alias_method :ids, :selected

  def available
    @available ||= Organization.where(id: Showing.search { facet(:organization_ids, limit: 500) }.facet(:organization_ids).rows.map(&:value)).
      order(:title).
      map { |o| { name: o.title, id: o.id } }
  end

  def used?
    selected.any?
  end
end

class TagsFilter
  attr_accessor :selected

  def initialize(tags, category = nil)
    @selected = (tags || []).delete_if(&:blank?)
    @category = category
  end

  def available
    options = @category ? { categories: [@category] } : {}
    @available ||= HasSearcher.searcher(:showings, options).actual.facets.facet(:tags).rows.map(&:value)
  end

  def used?
    selected.any?
  end
end

class GeoFilter
  attr_accessor :lat, :lon, :radius

  def initialize(lat, lon, radius)
    @lat, @lon, @radius = lat, lon, radius
  end

  def used?
    lat.present? && lon.present? && radius.present?
  end
end
