class Feature < ActiveRecord::Base
  attr_accessible :title

  belongs_to :organization_category

  scope :ordered_by_title, -> { order :title }
end
