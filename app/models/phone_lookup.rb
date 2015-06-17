class PhoneLookup < ActiveRecord::Base
  attr_accessible :organization_id
end

# == Schema Information
#
# Table name: phone_lookups
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

