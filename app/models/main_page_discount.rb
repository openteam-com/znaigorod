class MainPageDiscount < ActiveRecord::Base
  attr_accessible :discount_id, :position, :expires_at

  belongs_to :discount

  scope :ordered, -> { order :position }
  scope :actual, -> { where 'expires_at > ?', Time.zone.now }

  validates :expires_at, :presence => true

  def self.latest_discounts
    search = Discount.search do
      order_by :created_at, :desc
      paginate :page => 1, :per_page => 3
      with :state, :published
    end

    search.results
  end
end
