class ReviewArticle < Review
  attr_accessible :generate_poster

  attr_accessor :generate_poster

  validates :content, :presence => true
  validates :tag, :presence => true

  private

  def generate_poster?
    generate_poster == 'true'
  end

  def set_poster
    self.poster_image = Reviews::Content::Parser.new(content).poster if generate_poster? && !poster_url?
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
#

