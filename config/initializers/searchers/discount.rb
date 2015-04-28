HasSearcher.create_searcher :discounts do
  models :discount

  keywords :q

  property :type
  property :kind
  property :organization_ids

  property :without do |search|
    search.without [*search_object.without] if [*search_object.without].any?
  end

  scope do
    facet :kind, :sort => :count, :zero => true

    with :actual,               true
    with :copies_for_sale,      true
    with :state,                :published
  end

  scope :ends_as_greater_than_now do
    with(:ends_at).greater_than HasSearcher.cacheable_now
  end

  scope(:order_by_rating)   { order_by(:rating, :desc) }
  scope(:order_by_creation) { order_by(:created_at, :desc) }

  scope(:without_archive) { without :state, :archive }
end

HasSearcher.create_searcher :similar_discount do
  models :discount

  scope do
    with(:ends_at).greater_than HasSearcher.cacheable_now
    with :state, :published
  end
end
