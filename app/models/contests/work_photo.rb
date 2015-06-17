# encoding: utf-8

class WorkPhoto < Work
  validates_presence_of :image_url, :unless => :image?

  validates_attachment :image,
    :presence => true,
    :content_type => {
      :content_type => ['image/jpeg', 'image/jpg', 'image/png'],
      :message => 'Изображение должно быть в формате jpeg, jpg или png' }, :if => :image_url?

  validates :image, :dimensions => { :width_min => 300, :height_min => 300 }, :if => :image?

  def self.model_name
    Work.model_name
  end
end

# == Schema Information
#
# Table name: works
#
#  id                 :integer          not null, primary key
#  image_url          :text
#  author_info        :string(255)
#  context_id         :integer
#  title              :string(255)
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  slug               :string(255)
#  vk_likes           :integer
#  account_id         :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  context_type       :string(255)
#  rating             :float
#  video_url          :string(255)
#  code               :integer
#  type               :string(255)
#  video_content      :text
#  sms_counter        :integer          default(0)
#  anketa             :text
#

