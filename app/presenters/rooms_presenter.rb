class RoomsPresenter
  class PriceFilter
    attr_accessor :price_min, :price_max

    def initialize(price_min, price_max)
      @price_min, @price_max = price_min, price_max
    end

    def price_min
      @price_min || available_price_min
    end

    def price_max
      @price_max || available_price_max
    end

    def available_price_min
      0
    end

    def available_price_max
      DailyPrice.where(:context_type => 'Room').map { |d| [d.value, d.max_value] }.flatten.compact.max
    end
  end

  class CapacityFilter
    attr_accessor :capacity

    def initialize(capacity)
      @capacity = capacity
    end

    def capacity
      @capacity || capacity_min
    end

    def capacity_min
      1
    end

    def capacity_max
      Room.pluck(:capacity).max
    end
  end

  class RoomsFilter
    attr_accessor :rooms

    def initialize(rooms)
      @rooms = rooms
    end

    def rooms
      @rooms || rooms_min
    end

    def rooms_min
      1
    end

    def rooms_max
      Room.pluck(:rooms_count).max
    end
  end

  class FilterItem
    attr_accessor :title

    def initialize(title, selected)
      @title, @selected = title, selected
    end

    def selected?
      @selected
    end
  end

  class RoomFeaturesFilter
    attr_accessor :room_features

    def initialize(room_features)
      @room_features = room_features || []
    end

    def room_features
      available_room_features.map do |title|
        FilterItem.new title, @room_features.include?(title)
      end
    end

    def selected_features
      room_features.select(&:selected?)
    end

    def used?
      @room_features.delete_if(&:blank?).any?
    end

    def css_class
      used? ? 'show' : 'hide'
    end

    private

    def available_room_features
      Values.instance.room.features.map(&:mb_chars).map(&:downcase).map(&:to_s)
    end
  end

  class FeaturesFilter
    attr_accessor :features, :context_type

    def initialize(context_type, features)
      @context_type = context_type
      @features = features || []
    end

    def features
      available_features.map do |title|
        FilterItem.new title, @features.include?(title)
      end
    end

    def selected_features
      features.select(&:selected?)
    end

    def used?
      @features.delete_if(&:blank?).any?
    end

    def css_class
      used? ? 'show' : 'hide'
    end

    private

    def values_instance_data
      Values.instance.public_send context_type
    end

    def available_features
      values_instance_data.features.map(&:mb_chars).map(&:downcase).map(&:to_s)
    end
  end

  class OffersFilter
    attr_accessor :offers, :context_type

    def initialize(context_type, offers)
      @context_type = context_type
      @offers = offers || []
    end

    def offers
      available_offers.map do |title|
        FilterItem.new title, @offers.include?(title)
      end
    end

    def selected_offers
      offers.select(&:selected?)
    end

    def used?
      @offers.delete_if(&:blank?).any?
    end

    def css_class
      used? ? 'show' : 'hide'
    end

    private

    def values_instance_data
      Values.instance.public_send context_type
    end

    def available_offers
      values_instance_data.offers.map(&:mb_chars).map(&:downcase).map(&:to_s)
    end
  end

  include ActiveAttr::MassAssignment
  include OrganizationsPresenter

  acts_as_organizations_presenter kind: :hotel, filters: [:categories]

  attr_accessor :context_type,
                :categories,
                :price_min, :price_max,
                :capacity,
                :rooms,
                :room_features,
                :features,
                :offers,
                :lat, :lon, :radius,
                :page, :per_page, :search_query

  def initialize(context_type, args = {})
    @context_type = context_type

    super(args)

    normalize_arguments
  end

  def empty?
    context_id_group.total.zero?
  end

  def decorated_collection
    OrganizationDecorator.decorate organizations.sort{ |x,y|
      y.positive_activity_date && x.positive_activity_date ? y.positive_activity_date <=> x.positive_activity_date : y.positive_activity_date ? -1 : 1
    }
  end

  def paginatable_collection
    context_id_groups
  end

  delegate :price_min, :price_max, :available_price_min, :available_price_max, :to => :price_filter
  delegate :capacity, :capacity_min, :capacity_max,                            :to => :capacity_filter
  delegate :rooms, :rooms_min, :rooms_max,                                     :to => :rooms_filter
  delegate :room_features,                                                     :to => :room_features_filter
  delegate :features,                                                          :to => :features_filter
  delegate :offers,                                                            :to => :offers_filter

  def room_features_filter_css_class
    room_features_filter.css_class
  end

  def features_filter_css_class
    features_filter.css_class
  end

  def offers_filter_css_class
    offers_filter.css_class
  end

  def organizations_without_rooms
    @organizations_without_rooms ||= begin
                                      search = suborganization_class.search(:include => :organization) do
                                        paginate :page => 1, :per_page => 500
                                        fulltext search_query
                                        with :with_rooms, false
                                        with "#{context_type}_category", categories if categories.any?
                                      end

                                      OrganizationDecorator.decorate(search.results.map(&:organization))
                                     end
  end

  def last_page?
    total_pages = context_id_groups.total_pages

    total_pages.zero? ?  true : total_pages == page.to_i
  end

  private

  def kind
    context_type.to_s
  end

  def pluralized_kind
    context_type.to_s.pluralize
  end

  def normalize_arguments
    @context_type = ([:hotel, :recreation_center] & [@context_type.to_sym]).first

    raise "Unknown context type" unless @context_type

    @categories ||= []
    @room_features ||= []
    @features ||= []
    @offers ||= []
    @page ||= 1
    @per_page ||= per_page
    @search_query ||= search_query
  end

  def search
    @search ||= Room.search(:include => { :context => :organization }) do
      group :context_id

      any_of do
        with(:price_min).greater_than_or_equal_to(price_min) if price_min.present?
        with(:price_max).less_than_or_equal_to(price_max)    if price_max.present?
      end

      fulltext search_query

      paginate :page => page, :per_page => per_page

      with :context_type,  context_type
      with :status, :client

      with(:capacity).greater_than_or_equal_to(capacity_filter.capacity)
      with(:rooms_count).greater_than_or_equal_to(rooms_filter.rooms)

      with :categories,    categories                                          if categories.any?
      with :features,      features_filter.selected_features.map(&:title)      if features_filter.used?
      with :offers,        offers_filter.selected_offers.map(&:title)          if offers_filter.used?
      with :room_features, room_features_filter.selected_features.map(&:title) if room_features_filter.used?
    end
  end

  def context_id_group
    search.group(:context_id)
  end

  def context_id_groups
    context_id_group.groups
  end

  def context_ids
    context_id_groups.map(&:value)
  end

  def suborganization_class
    Hotel
  end

  def suborganizations
    suborganization_class.where(:id => context_ids).includes(:organization)
  end

  def organizations
    suborganizations.map(&:organization)
  end

  def collection
    @collection ||= organizations
  end

  def price_filter
    @price_filter ||= PriceFilter.new(@price_min, @price_max)
  end

  def capacity_filter
    @capacity_filter ||= CapacityFilter.new(@capacity)
  end

  def rooms_filter
    @rooms_filter ||= RoomsFilter.new(@rooms)
  end

  def room_features_filter
    @room_features_filter ||= RoomFeaturesFilter.new(@room_features)
  end

  def features_filter
    @features_filter ||= FeaturesFilter.new(context_type, @features)
  end

  def offers_filter
    @offers_filter ||= OffersFilter.new(context_type, @offers)
  end
end
