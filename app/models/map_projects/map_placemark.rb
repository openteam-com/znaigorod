include ImageHelper

class MapPlacemark < ActiveRecord::Base
  attr_accessor :related_items, :placemark_type # placemark_type = manual | relation

  attr_accessible :title, :map_layer_ids, :related_items, :latitude, :longitude, :url, :address,
                  :image, :kind, :expires_at, :placemark_type, :user_id

  validates_presence_of :map_layer_ids, :expires_at
  validates :related_items, presence: true, :if => :relation?
  validates :title, :latitude, :longitude, :url, :image, presence: true, :if => :manual?

  default_value_for :kind, 'custom'
  default_value_for :placemark_type, 'relation'

  scope :actual,    -> { where('expires_at > ?', Time.zone.now) }
  scope :published, -> { where(:state => :published) }
  scope :draft,     -> { where(:state => :draft) }

  before_save :parse_related_items
  before_destroy :delete_map_layers

  belongs_to :user
  has_many :map_relations, :dependent => :destroy
  has_many :map_layers, :through => :map_relations
  has_many :map_placemarks_payment, :as => :paymentable

  has_many :relations,      :as => :master,         :dependent => :destroy
  has_many :afishas,        :through => :relations, :source => :slave, :source_type => Afisha
  has_many :organizations,  :through => :relations, :source => :slave, :source_type => Organization
  has_many :discounts,      :through => :relations, :source => :slave, :source_type => Discount

  has_attached_file :image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  state_machine :initial => :draft do
    event :to_published do
      transition :draft => :published
    end

    event :to_draft do
      transition :published => :draft
    end
  end

  def delete_map_layers
    self.map_layers.delete_all
  end

  def actual?
    self.expires_at > Time.zone.now
  end

  def parse_related_items
    return if related_items.nil?

    relations.destroy_all

    related_items.each do |item|
      slave_type, slave_id = item.split("_")

      relation = relations.new
      relation.slave_type = slave_type.classify
      relation.slave_id = slave_id

      relation.save
    end

    relations.each do |relation|
      relation = relation.slave
      if relation.is_a? Organization
        self.title = relation.title
        self.latitude = relation.latitude
        self.longitude = relation.longitude
        self.image_url = relation.logotype_url.empty? ? resized_image_url('/assets/public/default_image.png', 190, 190, { :magnify => nil, :orientation => nil }) : resized_image_url(relation.logotype_url, 190, 190, { :magnify => nil, :orientation => nil })
        self.url = "/organizations/#{relation.slug}"
        self.kind = 'organization'
      end

      if relation.is_a? Afisha
        afisha_organization = relation.try(:organization)
        self.title = relation.title
        self.latitude = afisha_organization.try(:latitude) || relation.showings.first.try(:latitude)
        self.longitude = afisha_organization.try(:longitude) || relation.showings.first.try(:longitude)
        self.image_url = resized_image_url(relation.poster_url, 190, 260, { :magnify => nil, :orientation => nil })
        self.when = AfishaDecorator.new(relation).human_when
        self.url = "/afisha/#{relation.slug}"
        self.kind = 'afisha'
        self.organization_title = afisha_organization.title if afisha_organization
        self.organization_url = "/organizations/#{afisha_organization.slug}" if afisha_organization
      end

      if relation.is_a? Discount
        discount_organization = relation.try(:organization)
        self.title = relation.title
        self.latitude = discount_organization.try(:latitude)
        self.longitude = discount_organization.try(:longitude)
        self.image_url = resized_image_url(relation.poster_url, 160, 190, { :magnify => nil, :orientation => nil })
        self.url = "/discounts/#{relation.slug}"
        self.kind = 'discount'
        self.organization_title = discount_organization.title if discount_organization
        self.organization_url = "/organizations/#{discount_organization.slug}" if discount_organization
      end
    end
  end

  def manual?
    placemark_type == 'manual'
  end

  def relation?
    placemark_type == 'relation'
  end

  def published?
    state == 'published'
  end

  def draft?
    state == 'draft'
  end
end

# == Schema Information
#
# Table name: map_placemarks
#
#  id                 :integer          not null, primary key
#  title              :text
#  latitude           :float
#  longitude          :float
#  image_url          :text
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :string(255)
#  url                :text
#  when               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  kind               :string(255)
#  organization_title :text
#  organization_url   :text
#  expires_at         :datetime
#  state              :string(255)
#

