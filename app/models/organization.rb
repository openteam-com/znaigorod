# encoding: utf-8

class Organization < ActiveRecord::Base
  include HasVirtualTour
  include VkUpload
  include MakePageVisit
  include ImageHelper

  extend FriendlyId

  attr_accessible :address_attributes, :description, :email, :halls_attributes,
                  :images_attributes, :organization_id, :phone, :schedules_attributes,
                  :site, :subdomain, :title, :vfs_path, :attachments_attributes,
                  :logotype_url, :non_cash, :priority_suborganization_kind,
                  :comment, :organization_stand_attributes, :additional_rating,
                  :social_links_attributes, :user_id, :ability_to_comment,
                  :vkontakte_likes, :fb_likes, :odn_likes, :poster_vk_id,
                  :situated_at, :page_meta_keywords, :page_meta_description,
                  :page_meta_title, :og_description, :og_title, :positive_activity_date,
                  :photo_block_title, :discounts_block_title, :afisha_block_title, :reviews_block_title, :comments_block_title,
                  :barter_status,
                  :address_navigation_title, :discounts_navigation_title, :afishas_navigation_title, :reviews_navigation_title, :photos_navigation_title,
                  :organization_category_ids, :csv_id, :gis_title, :show_custom_balloon_icon

  ### <=== CRM

  attr_accessible :primary_organization_id, :balance_delta

  belongs_to :manager,              :class_name => 'User',         :foreign_key => 'user_id'
  belongs_to :organization
  belongs_to :placement,            :class_name => 'Organization', :foreign_key => 'situated_at'
  belongs_to :primary_organization, :class_name => 'Organization', :foreign_key => 'primary_organization_id'

  has_many :organization_category_items, :dependent => :destroy
  has_many :organization_categories, :through => :organization_category_items
  has_many :feature_organizations, :dependent => :destroy
  has_many :features, :through => :feature_organizations

  has_many :activities,             :dependent => :destroy
  has_many :comments,               :dependent => :destroy, :as => :commentable
  has_many :contacts,               :dependent => :destroy
  has_many :gallery_files,          :dependent => :destroy, :as => :attachable
  has_many :gallery_images,         :dependent => :destroy, :as => :attachable
  has_many :halls,                  :dependent => :destroy
  has_many :invitations,            :dependent => :destroy, :as => :inviteable
  has_many :organizations
  has_many :page_visits,            :dependent => :destroy, :as => :page_visitable
  has_many :phone_lookups,          :dependent => :destroy
  has_many :places
  has_many :schedules,              :dependent => :destroy
  has_many :showings,               :dependent => :destroy
  has_many :situated_organizations, :class_name => 'Organization', :foreign_key => 'situated_at'
  has_many :slave_organizations,    :class_name => 'Organization', :foreign_key => 'primary_organization_id'
  has_many :social_links,           :dependent => :destroy
  has_many :visits,                 :dependent => :destroy, :as => :visitable
  has_many :votes,                  :dependent => :destroy, :as => :voteable
  has_many :sections,               :dependent => :destroy

  has_many :afisha,            :through => :showings, :uniq => true
  has_many :certificates,      :through => :places, :source => :placeable, :source_type => 'Discount', :conditions => { 'discounts.type' => 'Certificate' }
  has_many :discounts,         :through => :places, :source => :placeable, :source_type => 'Discount'
  has_many :offered_discounts, :through => :places, :source => :placeable, :source_type => 'Discount', :conditions => { 'discounts.type' => 'OfferedDiscount' }
  has_many :sauna_halls,       :through => :sauna

  has_many :relations, :as => :slave, :dependent => :destroy
  has_many :reviews, :through => :relations, :source => :master, :source_type => Review

  has_one :address,             :dependent => :destroy
  has_one :organization_stand,  :dependent => :destroy

  extend Enumerize
  enumerize :status, :in => [:fresh, :talks, :waiting_for_payment, :client, :client_economy, :client_standart, :client_premium, :non_cooperation, :debtor],
              default: :fresh, predicates: true

  enumerize :barter_status, :in => [:no_information, :barter_implemented, :barter_not_implemented],
              predicates: true

  default_value_for :total_rating, 0

  def client?
    status.client? || status.client_economy? || status.client_standart? || status.client_premium?
  end

  def update_slave_organization_statuses
    slave_organizations.update_all :status => status

    slave_organizations.update_all :positive_activity_date => positive_activity_date if status == "client"
    slave_organizations.map(&:index)

  end

  ### CRM ===>

  ### <=== Payments

  def claimable_suborganizations
    @claimable_suborganizations ||= I18n.t('sms_claim').keys.map { |kind| send(kind) }.compact
  end

  def sms_claimable_suborganizations
    @sms_claimable_suborganizations ||= claimable_suborganizations.select(&:sms_claimable?)
  end

  def sms_claimable?
    sms_claimable_suborganizations.any?
  end

  def priority_sms_claimable_suborganization
    @priority_sms_claimable_suborganization ||= sms_claimable_suborganizations.include?(priority_suborganization) ? priority_suborganization : sms_claimable_suborganizations.first
  end

  ### Payments ===>

  def self.suborganization_kinds_for_navigation
    [Organization, Meal, Entertainment, CarSalesCenter, Culture, Sport, Creation, SalonCenter, Hotel].map(&:name).map(&:underscore)
  end

  def self.available_suborganization_kinds
    Dir[Rails.root.join('app/models/suborganizations/*.rb')].map { |f| f.split('/').last.gsub '.rb', '' } - ['shop']
  end

  available_suborganization_kinds.each do |kind|
    # без to_sym почему-то не работает добавление фоток к залу сауны
    has_one kind.to_sym, :dependent => :destroy
  end
  has_one :entertainment, :dependent => :destroy, :conditions => { type: nil }

  validates_presence_of :title
  validates_presence_of :organization_category_ids, :message => "* Категория не может быть пустой"

  validates  :email, :email_format => {
    :message => I18n.t('activerecord.errors.messages.invalid'),
    :allow_nil => true,
    :allow_blank => true
  }

  validates :site, :format => URI::regexp(%w(http https)), :if => :site?

  validates :phone, :phone => true, :if => :phone?

  accepts_nested_attributes_for :address,             :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :halls,               :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :organization_stand,  :reject_if => :all_blank
  accepts_nested_attributes_for :schedules,           :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :social_links,        :reject_if => :all_blank, :allow_destroy => true

  delegate :category, :cuisine, :feature, :offer, :payment,
           :to => :meal, :allow_nil => true, :prefix => true

  delegate :category, :feature, :offer, :payment,
           :to => :entertainment, :allow_nil => true, :prefix => true

  delegate :latitude, :longitude, :to => :address, :allow_nil => true

  scope :ordered_by_updated_at, order('updated_at DESC')
  scope :parental,              where(:organization_id => nil)

  alias_attribute :to_s, :title

  friendly_id :title, use: :slugged
  def should_generate_new_friendly_id?
    return true if !self.slug?

    false
  end

  paginates_per Settings['pagination.per_page'] || 10

  normalize_attribute :email, :with => [:strip, :blank]
  normalize_attribute :site,  :with => [:strip, :blank]

  alias_attribute :poster_url, :logotype_url
  alias_attribute :title_ru, :title
  alias_attribute :title_translit, :title
  alias_attribute :category_ru, :category
  alias_attribute :cuisine_ru, :cuisine
  alias_attribute :feature_ru, :feature
  alias_attribute :offer_ru, :offer
  alias_attribute :payment_ru, :payment
  alias_attribute :address_ru, :address

  def organization_category_uniq_slugs
    organization_categories.flat_map { |c| c.path }.uniq.map(&:slug)
  end

  def most_valueable_organization_category
    organization_categories.sort! { |a,b| b.organizations.count <=> a.organizations.count}.first
  end

  def map_image_name(slug, image_type = 'default')
    return resized_image_url(logotype_url, 50, 72) if show_custom_balloon_icon
    return most_valueable_organization_category.send("#{image_type}_image_url") unless slug

    organization_category = OrganizationCategory.find(slug)

    organization_category.is_root? ? most_valueable_organization_category.send("#{image_type}_image_url") :
      organization_category.send("#{image_type}_image_url")
  end

  searchable do
    boolean(:logotyped) { logotype_url? }
    boolean(:sms_claimable) { suborganizations.select {|s| s.respond_to?(:sms_claimable?)}.select {|s| s.sms_claimable?}.any? }
    boolean(:with_discounts) { discounts.actual.any? }

    float :rating
    float :total_rating
    string :primary_organization_id
    string :title

    integer :user_id
    integer :id

    latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }

    string :positive_activity_date
    string :search_kind
    string :status
    string :barter_status

    string(:inviteable_categories, :multiple => true) { ::Inviteables.instance.categories_for_organization self }
    string(:kind, :multiple => true)                  { ['organization'] }
    string(:organization_category_slugs, :multiple => true) { organization_category_uniq_slugs }
    string(:state)                                    { :published }
    string(:suborganizations, :multiple => true)      { suborganizations.map(&:class).map(&:name).map(&:underscore) }
    string(:organization_features, :multiple => true) { features.pluck(:title).uniq }

    text :title,                :boost => 1.0 * 1.2
    text :title_ru,             :boost => 1.0,              :more_like_this => true
    text :title_translit,       :boost => 0.0,                                        :stored => true
    text :category,             :boost => 0.5 * 1.2
    text :category_ru,          :boost => 0.5 * 1
    text :cuisine,              :boost => 0.5 * 1.2
    text :cuisine_ru,           :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :feature,              :boost => 0.5 * 1.2
    text :feature_ru,           :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :offer,                :boost => 0.5 * 1.2
    text :offer_ru,             :boost => 0.5 * 1,          :more_like_this => true,  :stored => true
    text :payment,              :boost => 0.5 * 1.2
    text :payment_ru,           :boost => 0.5 * 1,                                    :stored => true
    text :address,              :boost => 0.3 * 1.2
    text :address_ru,           :boost => 0.3,                                        :stored => true
    text :description,          :boost => 0.1 * 1.2                                                     do text_description end
    text :description_ru,       :boost => 0.1,                                        :stored => true   do text_description end

    text(:services_info) { services.map { |s| "#{s.title} #{s.description} #{s.category} #{s.feature}" }.join(' ') }

    text :term

    text :title, :as => :term_text
  end

  def likes_count
    self.votes.liked.count
  end

  def has_visit_for?(user)
    visits.where(:user_id => user).any?
  end

  def visit_for(user)
    visits.find_by_user_id(user)
  end

  def grouped_situated_organizations
    @grouped_situated_organizations ||= situated_organizations.group_by { |o| o.priority_suborganization.categories.first }
  end

  def invitations_and_visits_grouped_by_account
    {}.tap do |hash|
      visits.each do |visit|
        hash[visit.user.account] = {}
        hash[visit.user.account][:visit] = visit
        hash[visit.user.account][:invitations] = visit.user.account.invitations.without_invited.where(:inviteable_type => self.class.name, :inviteable_id => id)
      end
    end
  end

  def search_kind
    self.class.name.underscore
  end

  def term
   "#{title}, #{address}"
  end

  def as_json(options)
    super(:only => :id, :methods => [:term, :latitude, :longitude])
  end

  def nearest_afisha
    Afisha.where :id => Showing.unscoped.where('starts_at > :now AND organization_id = :organization_id',
                  { :now => DateTime.now.utc, :organization_id => id }).group(:afisha_id).pluck(:afisha_id)
  end

  def cuisine
    meal_cuisine
  end

  %w[category feature offer payment].each do |method|
    define_method method do
      suborganizations.map { |s| s.send(method) if s.respond_to?(method) }.delete_if(&:blank?).join(', ')
    end
  end

  %w[cuisine feature offer payment].each do |method|
    define_method "#{method}?" do
      send(method).present?
    end
  end

  def index_suborganizations
    suborganizations.map(&:sunspot_index)
  end

  def self.grouped_collection_for_select
    Organization.where(:organization_id => nil).order(:title)
  end

  def html_description
    @html_description ||= description.try(:as_html)
  end

  def text_description
    @text_description ||= html_description.try(:as_text)
  end

  auto_html_for :description do
    youtube :width => 580, :height => 350
    vimeo :width => 580, :height => 350
    redcloth
    external_links_attributes
    external_links_redirect
  end

  def self.inherited_suborganization_kinds
    available_suborganization_kinds.map(&:classify).map(&:constantize).flat_map(&:descendants).map(&:name).map(&:downcase)
  end

  def self.basic_suborganization_kinds
    available_suborganization_kinds - inherited_suborganization_kinds
  end

  def available_suborganization_kinds
    self.class.available_suborganization_kinds
  end

  def self.available_suborganization_classes
    available_suborganization_kinds.map(&:classify).map(&:constantize)
  end

  def suborganizations
    available_suborganization_kinds.map { |kind| send(kind) }.compact
  end

  def services
    Service.where :id => suborganizations.select{ |s| s.respond_to?(:services) }.flat_map(&:service_ids)
  end

  def rooms
    Room.where :id => suborganizations.select{ |s| s.respond_to?(:rooms) }.flat_map(&:room_ids)
  end

  def priority_suborganization
    return nil unless priority_suborganization_kind?

    send priority_suborganization_kind
  end

  def rating_position
    count = self.class.count

    self.class.solr_search_ids { order_by(:total_rating, :desc); paginate(:page => 1, :per_page => count) }.index(id) + 1
  end

  def images
    gallery_images
  end

  def navigation_collection
    {}.tap do |hash|
      %w[address photos].each do |prefix|
        hash[send("#{prefix}_navigation_title")] = send("#{prefix}_navigation_title").from_russian_to_param if send("#{prefix}_navigation_title").present?
      end

      sections.order('position').select { |s| s.navigation_title.present? }.each do |section|
        hash[section.navigation_title] = section.navigation_title.from_russian_to_param
      end

      %w[discounts afishas reviews].each do |prefix|
        hash[send("#{prefix}_navigation_title")] = send("#{prefix}_navigation_title").from_russian_to_param if send("#{prefix}_navigation_title").present?
      end
    end
  end

  def update_rating
    OrganizationObserver.disabled = true

    update_attribute :total_rating, votes.liked.count

    OrganizationObserver.disabled = false
  end

  def title_and_address
    "#{title} (#{address.try(:street)}, #{address.try(:house)})"
  end
end

# == Schema Information
#
# Table name: organizations
#
#  id                            :integer          not null, primary key
#  title                         :text
#  site                          :text
#  email                         :text
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  phone                         :text
#  vfs_path                      :string(255)
#  organization_id               :integer
#  logotype_url                  :text
#  slug                          :string(255)
#  rating                        :float
#  non_cash                      :boolean
#  priority_suborganization_kind :string(255)
#  comment                       :text
#  additional_rating             :integer
#  yandex_metrika_page_views     :integer
#  vkontakte_likes               :integer
#  subdomain                     :string(255)
#  user_id                       :integer
#  status                        :string(255)
#  total_rating                  :float
#  primary_organization_id       :integer
#  ability_to_comment            :boolean          default(TRUE)
#  fb_likes                      :integer
#  odn_likes                     :integer
#  poster_vk_id                  :string(255)
#  situated_at                   :integer
#  page_meta_description         :text
#  page_meta_keywords            :text
#  page_meta_title               :text
#  positive_activity_date        :datetime
#  og_description                :text
#  og_title                      :text
#  site_link_counter             :integer          default(0)
#  photo_block_title             :string(255)      default("Фото")
#  discounts_block_title         :string(255)      default("Скидки")
#  afisha_block_title            :string(255)      default("Афиша")
#  reviews_block_title           :string(255)      default("Обзоры")
#  comments_block_title          :string(255)      default("Отзывы")
#  barter_status                 :string(255)      default("no_information")
#  discounts_navigation_title    :string(255)
#  photos_navigation_title       :string(255)
#  afishas_navigation_title      :string(255)
#  reviews_navigation_title      :string(255)
#  address_navigation_title      :string(255)
#  csv_id                        :integer
#

