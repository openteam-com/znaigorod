class Discount < ActiveRecord::Base
  include AutoHtml
  include CropedPoster
  include DraftPublishedStates
  include EmailNotifications
  include MakePageVisit
  include VkUpload

  attr_accessor :place_attributes

  attr_accessible :title, :description, :ends_at, :kind, :starts_at,
                  :discount, :organization_title, :constant, :sale,
                  :place_attributes, :discount_type, :stale, :account_id, :published_at, :promoted_at

  belongs_to :account
  belongs_to :afisha

  has_many :comments,       :dependent => :destroy, :as => :commentable
  has_many :copies,         :dependent => :destroy, :as => :copyable
  has_many :members,        :dependent => :destroy, :as => :memberable
  has_many :messages,       :dependent => :destroy, :as => :messageable
  has_many :offers,         :dependent => :destroy, :as => :offerable, :order => 'offers.id DESC'
  has_many :page_visits,    :dependent => :destroy, :as => :page_visitable
  has_many :places,         :dependent => :destroy, :as => :placeable
  has_many :votes,          :dependent => :destroy, :as => :voteable
  has_many :promote_discount_payments,              :as => :paymentable

  has_many :accounts, :through => :members
  has_many :organizations, :through => :places
  has_one :feed, :as => :feedable, :dependent => :destroy

  validates_presence_of :title, :description, :kind

  validates_presence_of :discount,            :unless => :sale?
  validates_presence_of :starts_at, :ends_at, :unless => :constant?

  after_save :reindex_organizations
  after_save :parse_place_attributes
  after_destroy :reindex_organizations

  scope :actual, -> { where "ends_at > ? OR constant = ?", Time.zone.now, true }

  alias_attribute :message_for_sms, :title
  alias_attribute :to_s, :title

  extend Enumerize
  serialize :kind, Array
  enumerize :kind, :in => [:auto, :cafe, :entertainment, :beauty, :technique, :wear, :birthday, :travel, :home, :children, :other, :students, :photo, :study],
                   :multiple => true,
                   :predicates => true

  enumerize :discount_type, :in =>[:rubles, :percentages]

  normalize_attribute :kind, :with => :blank_array

  has_croped_poster min_width: 220, min_height: 164

  default_value_for :stale, false

  alias_attribute :title_ru,       :title
  alias_attribute :description_ru, :description

  searchable do
    boolean(:actual)          { actual? }
    boolean(:copies_for_sale) { copies_for_sale? }

    time :created_at, :trie => true
    time :promoted_at, :trie => true

    float(:rating) { total_rating }

    integer :organization_ids, :multiple => true

    string(:kind, :multiple => true) { kind.map(&:value) }
    string(:type) { type_for_solr }
    string(:search_kind) { :discount }
    string :state

    text :address,        :boost => 0.3 * 1.2
    text :address_ru,     :boost => 0.3
    text :description,    :boost => 0.1 * 1.2
    text :description_ru, :boost => 0.1, :stored => true
    text :title,          :boost => 1.0 * 1.2, :stored => true
    text :title_ru,       :boost => 1.0, :more_like_this => true

    time :ends_at, :trie => true
  end

  def parse_place_attributes
    return true unless place_attributes

    places.destroy_all

    if place_attributes[:organization_ids]
      place_attributes[:organization_ids].each do |place|
        place_type, place_id = place.split("_")
        new_place = places.new
        new_place.organization_id = place_id
        new_place.save
      end
    end

    if place_attributes[:address].present?
      new_place = places.new
      new_place.address = place_attributes[:address]
      new_place.latitude = place_attributes[:latitude]
      new_place.longitude = place_attributes[:longitude]
      new_place.save
    end
  end

  def self.classes_subtree
    descendants.unshift self
  end

  def organizations_titles
    return if organizations.empty?
    organizations.map(&:title).join(' ')
  end

  def organization
    organizations.first
  end

  def type_for_solr
    self.class.name.underscore
  end

  def address
    places.pluck(:address).join(' ')
  end
  alias_method :address_ru, :address

  extend FriendlyId
  friendly_id :title, :use => :slugged
  def should_generate_new_friendly_id?
    return true if !self.slug? && self.published?

    false
  end

  def html_description
    @html_description ||= description.to_s.as_html
  end

  auto_html_for :description do
    youtube :width => 580, :height => 350
    vimeo :width => 580, :height => 350
    redcloth
    external_links_attributes
    external_links_redirect
  end

  def likes_count
    self.votes.liked.count
  end

  def update_rating
    update_attribute :total_rating, (copies.sold.count +
                                     0.5 * members.count +
                                     0.1 * votes.liked.count +
                                     0.01 * page_visits.count)
  end

  def actual?
    constant? ? true : ends_at > Time.zone.now
  end

  def copies_for_sale?
    true
  end

  def reindex_organizations
    organizations.each do |organization|
      organization.delay.index
      organization.delay.index_suborganizations
    end
  end
  alias_method :sunspot_index, :reindex_organizations

  def ready_for_publication?
    title.present? && description.present? && poster_image_url? && draft?
  end

  def has_member_for?(account)
    members.where(:account_id => account).any?
  end

  def member_for(account)
    members.find_by_account_id(account)
  end

  def free?
    price? ? price.zero? : true
  end

  def can_be_deleted?
    return false if copies.where('copies.state IN (?)', [:reserved, :sold]).any?

    return false if published?

    true
  end
end

# == Schema Information
#
# Table name: discounts
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  description               :text
#  poster_url                :text
#  type                      :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  poster_image_url          :text
#  starts_at                 :datetime
#  ends_at                   :datetime
#  slug                      :string(255)
#  total_rating              :float
#  kind                      :text
#  number                    :integer
#  origin_price              :integer
#  price                     :integer
#  discounted_price          :integer
#  discount                  :integer
#  payment_system            :string(255)
#  state                     :string(255)
#  account_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  constant                  :boolean
#  sale                      :boolean          default(FALSE)
#  poster_vk_id              :text
#  terms                     :text
#  supplier                  :text
#  placeholder               :text
#  afisha_id                 :integer
#  external_id               :string(255)
#  discount_type             :string(255)
#  email_addresses           :text
#  stale                     :boolean
#  published_at              :datetime
#  archived_at               :datetime
#  promoted_at               :datetime
#

