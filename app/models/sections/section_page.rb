class SectionPage < ActiveRecord::Base
  attr_accessible :title, :content, :poster, :vfs_path,
                  :poster_image, :position

  validates_presence_of :title, :content

  has_many :gallery_images,        :as => :attachable,     :dependent => :destroy
  belongs_to :section

  scope :order_by_position, order(:position)

  has_attached_file :poster_image, storage: :elvfs, elvfs_url: Settings['storage.url']

  def self.generate_vfs_path
    "/znaigorod/section_pages/#{Time.now.strftime('%Y/%m/%d/%H-%M')}-#{SecureRandom.hex(4)}"
  end

  def content_for_show(sanitize = true, options = {})
    if sanitize
      sanitize(cached_content_for_show.try(:html_safe), :tags => %w(ul li h3 p b strong strike span), :attributes => ['id', 'class', 'style']) # tags => allowed tags
    else
      cached_content_for_show.try(:html_safe)
    end
  end
end

# == Schema Information
#
# Table name: section_pages
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  content                   :text
#  section_id                :integer
#  poster_image_url          :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  vfs_path                  :string(255)
#  position                  :integer
#

