class OrganizationNavigation < ActiveRecord::Base
  attr_accessible :title, :href, :position, :organization_id

  validates_presence_of :title, :href, :organization_id

  before_save :set_original_href
  before_save :set_href

  belongs_to :organization

  scope :ordered, order('position')

  def set_href
    self.href = href.from_russian_to_param
  end

  def set_original_href
    self.original_href = href
  end
end

# == Schema Information
#
# Table name: organization_navigations
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  original_href   :string(255)
#  href            :string(255)
#  position        :integer
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

