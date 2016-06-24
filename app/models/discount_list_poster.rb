class DiscountListPoster < ActiveRecord::Base
  attr_accessible :position, :expires_at, :discount_id

  belongs_to :discount

  scope :ordered, -> { order :position }
  scope :actual, -> { where 'expires_at > ?', Time.zone.now }
end
