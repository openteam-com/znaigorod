class OrganizationCategory < ActiveRecord::Base
  extend FriendlyId

  alias_attribute :to_s, :title
  attr_accessible :title, :parent, :slug, :default_image, :hover_image

  default_scope order('title')

  has_many :organization_category_items, :dependent => :destroy

  has_many :review_category_items, :dependent => :destroy
  has_many :reviews, :through => :review_category_items

  has_many :features, :dependent => :destroy

  has_attached_file :default_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  has_attached_file :hover_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  validates :title, presence: true, uniqueness: { scope: :ancestry }
  validates_presence_of :slug

  friendly_id :title, :use => :slugged

  has_ancestry

  def root_category?
    root.present? ? true : false
  end

  def self.used_roots
    OrganizationCategory.roots.where('title NOT IN (?)', ['Автосервис', 'Туристические агентства','Магазины'])
  end

  def should_generate_new_friendly_id?
    slug? ? false : true
  end

  def organizations
    Organization.joins(:organization_categories).where(:organization_categories => { :id => subtree_ids }).uniq
  end

  def all_features
    if is_root?
      features
    else
      Feature.where :id => root.feature_ids + feature_ids
    end
  end

  def downcased_title
    title.mb_chars.downcase.to_s
  end

  def available_kinds
    I18n.t('organization.kind').invert.inject({}) { |h, (k, v)| h[k.mb_chars.downcase.to_s] = v.to_s; h }
  end

  def kind
    parent ? available_kinds[parent.downcased_title] : available_kinds[downcased_title]
  end
end

# == Schema Information
#
# Table name: organization_categories
#
#  id                         :integer          not null, primary key
#  title                      :string(255)
#  ancestry                   :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  slug                       :string(255)
#  default_image_file_name    :string(255)
#  default_image_content_type :string(255)
#  default_image_file_size    :integer
#  default_image_updated_at   :datetime
#  default_image_url          :text
#  hover_image_file_name      :string(255)
#  hover_image_content_type   :string(255)
#  hover_image_file_size      :integer
#  hover_image_updated_at     :datetime
#  hover_image_url            :text
#

