class FeatureOrganization < ActiveRecord::Base
  belongs_to :feature
  belongs_to :organization

  validates :feature_id, :uniqueness => { :scope => :organization_id }
end

# == Schema Information
#
# Table name: feature_organizations
#
#  id              :integer          not null, primary key
#  feature_id      :integer
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

