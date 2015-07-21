# encoding: utf-8

class ContestVideo < Contest
  def self.model_name
    Contest.model_name
  end
end

# == Schema Information
#
# Table name: contests
#
#  id                    :integer          not null, primary key
#  title                 :string(255)
#  description           :text
#  starts_at             :datetime
#  ends_at               :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  vfs_path              :string(255)
#  slug                  :string(255)
#  og_description        :text
#  og_image_file_name    :string(255)
#  og_image_content_type :string(255)
#  og_image_file_size    :integer
#  og_image_updated_at   :datetime
#  og_image_url          :text
#  agreement             :text
#  participation_ends_at :datetime
#  type                  :string(255)
#  vote_type             :string(255)
#  sms_prefix            :string(255)
#  short_number          :integer
#  sms_secret            :string(255)
#  default_sort          :string(255)      default("by_id")
#  new_work_text         :string(255)      default("Добавить фотографию")
#  placeholder           :text
#  email                 :string(255)
#  anketa_content        :text
#  subject               :string(255)
#

