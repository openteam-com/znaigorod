class ReviewVideo < Review
  attr_accessible :video_url, :reset_poster

  attr_accessor :reset_poster

  before_save :reset_poster_url, :if => :reset_poster?

  validates :video_url, :presence => true
  validates :tag, :presence => true

  def content_parser
    @content_parser ||= Reviews::Content::Videos.new(video_url)
  end

  private

  def set_poster
    self.poster_image = Reviews::Content::Parser.new(video_url).poster if reset_poster?
  end

  def reset_poster?
    reset_poster == 'true'
  end

  def reset_poster_url
    self.poster_url = nil
  end
end

# == Schema Information
#
# Table name: reviews
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  type                      :string(255)
#  content                   :text
#  slug                      :string(255)
#  tag                       :text
#  categories                :text
#  state                     :string(255)
#  account_id                :integer
#  allow_external_links      :boolean
#  video_url                 :text
#  poster_image_url          :text
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  poster_url                :text
#  rating                    :float
#  cached_content_for_index  :text
#  cached_content_for_show   :text
#  poster_vk_id              :text
#  only_tomsk                :boolean
#  contest_id                :integer
#  old_slug                  :string(255)
#  only_sevastopol           :boolean
#

