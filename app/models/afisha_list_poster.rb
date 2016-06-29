class AfishaListPoster < ActiveRecord::Base
  attr_accessible :position, :expires_at, :afisha_id

  belongs_to :afisha

  scope :ordered, -> { order :position }
  scope :actual, -> { where 'expires_at > ?', Time.zone.now }
end

# == Schema Information
#
# Table name: afisha_list_posters
#
#  id         :integer          not null, primary key
#  position   :integer
#  expires_at :datetime
#  afisha_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

