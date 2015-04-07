class Feature < ActiveRecord::Base
  attr_accessible :title

  belongs_to :organization_category

  scope :ordered_by_title, -> { order :title }
end

# == Schema Information
#
# Table name: features
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  organization_category_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

