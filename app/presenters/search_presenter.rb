class SearchPresenter

  attr_accessor :params
  attr_reader :kind_filter, :query, :page, :per_page, :ya_addresses_search

  def initialize(params)
    @kind_filter = KindFilter.new(params['search_kind'])
    @query = params['q']
    @page = params['page']
    @page ||= 1
    @per_page = 10
    @ya_addresses_search = YandexAddressesSearch.new(params['q'], @page)
  end

  def searcher
    @searcher ||= HasSearcher.searcher(:global, searcher_parameters)
  end

  def searcher_parameters
    @searcher_parameters ||= {}.tap do |searcher_parameters|
      searcher_parameters[:q] = @query
      searcher_parameters[:search_kind] = @kind_filter.search_kind unless @kind_filter.search_all?
    end
  end

  def collection
    @collection ||= searcher.paginate(page: page, per_page: per_page)
  end

  def paginated_collection
    @kind_filter.search_address? ? @ya_addresses_search.collection : collection.results
  end

  def hits
    HitDecorator.decorate(collection.hits).select { |h| h.result }
  end

  def hits?
    collection.any? || @ya_addresses_search.collection.any?
  end

  def render_addresses?
    @ya_addresses_search.collection.any? && @kind_filter.search_all?
  end

  def kinds_links
    @kinds_links ||= [].tap { |array|
      @kind_filter.available_kind_values.each do  |kind|
        array << {
          title: I18n.t("search_kinds.#{kind}"),
          klass: kind,
          parameters: {
            q: @query,
            search_kind: kind
          },
          current: kind == @kind_filter.search_kind,
          count: SearchCounter.new(self, kind, @query).count(@ya_addresses_search)
        }
      end
   }
  end
end

class KindFilter

  attr_accessor :search_kind

  def initialize(search_kind)
    @search_kind = search_kind
    @serch_kind ||= 'all'
  end

  def self.available_kind_values
    %w[all afisha organization discount review account address]
  end

  def available_kind_values
    self.class.available_kind_values
  end

  def search_kind
    available_kind_values.include?(@search_kind) ? @search_kind : 'all'
  end

  available_kind_values.each do |kind|
    define_method "search_#{kind}?" do
      search_kind == kind
    end
  end
end

class SearchCounter
  attr_accessor :presenter, :search_kind

  def initialize(presenter, search_kind, query)
    @presenter = presenter
    @search_kind = search_kind
    @search_kind = nil if search_kind == 'all'
    @query = query if query != nil
  end

  def count ya_addresses_search
    case search_kind
    when 'address'
      ya_addresses_search.total
    when nil
      ya_addresses_search.total + HasSearcher.searcher(:global, presenter.searcher_parameters.merge(:search_kind => search_kind)).total
    else
      HasSearcher.searcher(:global, presenter.searcher_parameters.merge(:search_kind => search_kind)).total
    end
  end
end

class YandexAddressesSearch
  attr_accessor :query, :collection, :total, :address, :houses

  def initialize(query, page)
    @query = query
    @page = page
    @per_page = 20
    @result =  YampGeocoder.get_addresses(@query)
    @houses ||= @result[:houses]
    @address ||= @result[:address]
  end

  def total
    if @result[:houses].present?
      @total ||= @result[:houses].size()
    else
      @total ||= 0
    end
    return @total
  end

  def collection
    if @houses.present? && @address.present?
      return Kaminari.paginate_array(@houses).page(@page).per(@per_page)
    end
    return {}
  end
end

