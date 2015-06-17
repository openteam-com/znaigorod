class OrganizationCategory < ActiveRecord::Base
  extend FriendlyId
  extend Enumerize

  attr_accessor :sort_flag

  alias_attribute :to_s, :title
  attr_accessible :title, :parent, :slug, :default_image, :hover_image, :afisha_kind, :show_on_main_page, :afisha_per_page

  has_many :organization_category_items, :dependent => :destroy

  has_many :review_category_items, :dependent => :destroy

  has_many :features, :dependent => :destroy

  has_attached_file :default_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  has_attached_file :hover_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  validates :title, presence: true, uniqueness: { scope: :ancestry }
  validates_presence_of :slug

  after_update :reindex_related_organizations, :unless => :sort_flag
  after_save { Znaigorod::Application.reload_routes! }

  friendly_id :title, :use => :slugged

  serialize :afisha_kind, Array
  enumerize :afisha_kind,
    in: AfishaKind.new.send(Settings["app.city"]),
    multiple: true

  has_ancestry

  def root_category?
    root.present? ? true : false
  end

  def reindex_related_organizations
    organizations.each do |org|
      org.delay.index
      org.meal.delay.index if org.meal
      org.sauna.sauna_halls.map{ |sauna_hall| sauna_hall.delay.index } if org.sauna
      org.hotel.rooms.map{ |room| room.delay.index } if org.hotel
    end
  end

  def should_generate_new_friendly_id?
    slug? ? false : true
  end

  def reviews
    Review.joins(:organization_categories).where(:organization_categories => { :id => subtree_ids }).uniq
  end

  def organizations
    Organization.joins(:organization_categories).where(:organization_categories => { :id => subtree_ids }).uniq
  end

  def self.show_on_main_page
    where(:show_on_main_page => true).order(:position).take(9)
  end

  def all_features
    is_root? ? features : Feature.where(:id => root.feature_ids + feature_ids)
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
#  position                   :integer          default(1)
#  afisha_kind                :text
#  show_on_main_page          :boolean
#  afisha_per_page            :integer          default(1000)
#

