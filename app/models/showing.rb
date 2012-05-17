class Showing < ActiveRecord::Base
  attr_accessible :hall, :place, :price, :starts_at

  belongs_to :affiche

  validates_presence_of :affiche, :hall, :place, :price, :starts_at

  default_scope order(:starts_at)
end

# == Schema Information
#
# Table name: showings
#
#  id         :integer         not null, primary key
#  affiche_id :integer
#  place      :string(255)
#  starts_at  :datetime
#  price      :integer
#  hall       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

