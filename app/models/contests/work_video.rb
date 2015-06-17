# encoding: utf-8

class WorkVideo < Work
  attr_accessible :video_url, :code, :image_url

  validates :video_url, :presence => true
  validates :code, :presence => true

  before_save :set_poster, :store_video_content

  def set_poster
    self.image = Reviews::Content::Parser.new(video_url).poster
  end

  def content_parser
    @content_parser ||= Reviews::Content::Videos.new(video_url)
  end

  def store_video_content
    self.video_content = AutoHtmlRenderer.new(video_url).render_show
  end

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

