class OrganizationNavigation < ActiveRecord::Base
  attr_accessible :title, :href, :position, :organization_id

  validates_presence_of :title, :href

  #before_save :set_href

  belongs_to :organization

  #def set_href
    #self.href = title.from_russian_to_param
  #end
end

# == Schema Information
#
# Table name: organization_navigations
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  href            :string(255)
#  position        :integer
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

