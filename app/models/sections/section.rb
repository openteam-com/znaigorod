class Section < ActiveRecord::Base
  attr_accessible :title, :navigation_title

  has_many :section_pages, :dependent => :destroy
  belongs_to :organization

  scope :order_by_position, order('position')
end

# == Schema Information
#
# Table name: sections
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  organization_id  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer
#  navigation_title :string(255)
#

