# encoding: utf-8

class GalleryImage < Attachment
  has_attached_file :file, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  after_save :message_about_update
  validates_attachment :file, :presence => true, :content_type => {
    :content_type => ['image/jpeg', 'image/jpg', 'image/png'],
    :message => 'Изображение должно быть в формате jpeg, jpg или png' }

  def message_about_update
    if attachable.class.name == 'Organization'
      MyMailer.associated_changes(attachable, 'галерея изображений').deliver
    end
  end
end

# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  attachable_id     :integer
#  attachable_type   :string(255)
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#  thumbnail_url     :text
#  height            :integer
#  width             :integer
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_url          :text
#  file_image_url    :string(255)
#  position          :integer
#  user_id           :integer
#

