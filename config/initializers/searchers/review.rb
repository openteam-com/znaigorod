HasSearcher.create_searcher :reviews do
  models :review

  property :type
  property :category

  scope do
    facet :category, :sort => :count, :zero => true

    with :state, :published
  end

  scope :without_eighteen_plus do
    without :category, :eighteen_plus
  end

  scope :only_tomsk do
    with :only_tomsk, true
  end

  scope(:order_by_commented)  { order_by(:commented, :desc) }
  scope(:order_by_creation)   { order_by(:created_at, :desc) }
  scope(:order_by_rating)     { order_by(:rating, :desc) }
end
