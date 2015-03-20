class FeatureOrganization < ActiveRecord::Base
  belongs_to :feature
  belongs_to :organization

  validates :feature_id, :uniqueness => { :scope => :organization_id }
end
