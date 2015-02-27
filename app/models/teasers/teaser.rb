class Teaser < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :items_quantity, :title

  validates_presence_of :title
  validates_presence_of :items_quantity
  has_many :teaser_items, :dependent => :destroy

  friendly_id :title, :use => :slugged
  def should_generate_new_friendly_id?
    return true if !self.slug?

    false
  end
end

# == Schema Information
#
# Table name: teasers
#
#  id             :integer          not null, primary key
#  items_quantity :integer
#  border_color   :string(255)
#  title          :string(255)
#  slug           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  with_relations :boolean
#

