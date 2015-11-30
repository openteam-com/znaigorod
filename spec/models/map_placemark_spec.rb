require 'spec_helper'

describe MapPlacemark do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: map_placemarks
#
#  id                 :integer          not null, primary key
#  title              :text
#  latitude           :float
#  longitude          :float
#  image_url          :text
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :string(255)
#  url                :text
#  when               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  kind               :string(255)
#  organization_title :text
#  organization_url   :text
#  expires_at         :datetime
#  state              :string(255)
#  user_id            :integer
#

