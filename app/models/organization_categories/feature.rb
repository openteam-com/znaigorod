class Feature < ActiveRecord::Base
  attr_accessible :title
  belongs_to :organization_category
end
