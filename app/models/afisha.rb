# encoding: utf-8

require 'vkontakte_api'
require 'curb'

class Afisha < ActiveRecord::Base
  extend Enumerize

  include Album::Downloader
  include AutoHtml
  include CropedPoster
  include DraftPublishedStates
  include HasVirtualTour
  include MakePageVisit
  include VkUpload

  attr_accessible :description, :poster_url, :image_url, :showings_attributes,
                  :tag, :title, :vfs_path, :affiche_schedule_attributes,
                  :images_attributes, :attachments_attributes,
                  :distribution_starts_on, :distribution_ends_on,
                  :original_title, :trailer_code, :vk_aid, :yandex_fotki_url, :constant,
                  :age_min, :age_max, :state_event, :state, :user_id, :kind, :vk_event_url,
                  :fb_likes, :odn_likes, :vkontakte_likes, :poster_vk_id, :bkz_link,
                  :promoted_at

  attr_accessible :year, :art_directors, :editors, :film_created_in, :slogan, :producer, :director, :scenario, :operator, :compositor,
                :stars, :genre, :premiere_world, :premiere_RF, :genre,
                :age_category, :duration

  attr_accessor :year, :art_directors, :editors, :film_created_in, :slogan, :producer, :scenario, :director, :operator, :compositor,
                :stars, :genre, :premiere_world, :premiere_RF, :genre,
                :age_category, :duration

  belongs_to :user

  has_many :all_images,            :as => :attachable, :class_name => 'Attachment', :conditions => { :type => %w[GalleryImage GallerySocialImage] }

  has_many :comments,                 :dependent => :destroy, :as => :commentable
  has_many :discounts,                :dependent => :destroy
  has_many :gallery_files,            :dependent => :destroy, :as => :attachable
  has_many :gallery_images,           :dependent => :destroy, :as => :attachable
  has_many :gallery_social_images,    :dependent => :destroy, :as => :attachable
  has_many :invitations,              :dependent => :destroy, :as => :inviteable
  has_many :messages,                 :dependent => :destroy, :as => :messageable
  has_many :page_visits,              :dependent => :destroy, :as => :page_visitable
  has_many :ponominalu_tickets,       :dependent => :destroy, :order => 'id'
  has_many :promote_afisha_payments,                          :as => :paymentable
  has_many :showings,                 :dependent => :destroy, :order => :starts_at
  has_many :tickets,                  :dependent => :destroy
  has_many :versions,                 :dependent => :destroy, :as => :versionable, :order => 'id ASC'
  has_many :visits,                   :dependent => :destroy, :as => :visitable
  has_many :votes,                    :dependent => :destroy, :as => :voteable

  has_many :addresses,     :through => :organizations, :uniq => true, :source => :address
  has_many :copies,        :through => :tickets
  has_many :organizations, :through => :showings, :uniq => true

  has_many :relations, :as => :slave
  has_many :reviews, :through => :relations, :source => :master, :source_type => Review

  has_one :affiche_schedule, :dependent => :destroy
  has_one :feed, :as => :feedable, :dependent => :destroy
  has_one :reservation, :as => :reserveable, :dependent => :destroy
  serialize :kind, Array
  enumerize :kind,
    in: AfishaKind.new.send(Settings["app.city"]),
    multiple: true,
    predicates: true

  normalize_attribute :kind, with: :blank_array

  validates_presence_of :kind, :title, :description

  accepts_nested_attributes_for :affiche_schedule, :allow_destroy => true, :reject_if => :afisha_schedule_attributes_blank?
  accepts_nested_attributes_for :showings, :allow_destroy => true

  default_scope order('afisha.id DESC')


  scope :latest,           ->(count) { limit(count) }
  scope :with_images,      -> { where('image_url IS NOT NULL') }
  scope :with_showings,    -> { includes(:showings).where('showings.starts_at > :date OR showings.ends_at > :date', { :date => Date.today }) }
  scope :with_event_url,   -> { where('vk_event_url IS NOT NULL') }

  default_value_for :yandex_metrika_page_views, 0
  default_value_for :vkontakte_likes,           0
  default_value_for :total_rating,              0

  before_save :prepare_trailer
  before_save :build_description
  before_save :set_wmode_for_trailer, :if => :published?

  scope :actual,                -> { includes(:showings).where('showings.starts_at >= ? OR (showings.ends_at is not null AND showings.ends_at > ?)', DateTime.now.beginning_of_day, Time.zone.now).uniq }
  scope :archive,               -> { joins(:showings).where('showings.starts_at < ? OR (showings.ends_at is not null AND showings.ends_at < ?)', DateTime.now.beginning_of_day, Time.zone.now).uniq }
  scope :on_weekend,            -> { includes(:showings).where('showings.starts_at >= ? and  showings.starts_at <= ?', Time.zone.now.end_of_week - 2.days, Time.zone.now.end_of_week) }

  normalize_attribute :image_url

  has_croped_poster min_width: 200, min_height: 269

  extend FriendlyId
  friendly_id :title, :use => :slugged
  def should_generate_new_friendly_id?
    return true if !self.slug? && self.published?

    false
  end

  attr_accessor :step, :social_gallery_url
  attr_accessible :step, :social_gallery_url

  def self.available_tags(query)
    begin
      pluck(:tag).compact.flat_map { |str| str.split(',') }.compact.map(&:squish).uniq.delete_if(&:blank?).select { |str| str =~ /^#{query}/ }.sort
    rescue
    end
  end

  def self.steps
    %w[first second third fourth fifth sixth]
  end

  steps.each do |step|
    define_method("#{step}_step?") { self.step == step }
  end

  def ready_for_publication?
    title.present? && description.present? && poster_url.present? && showings.any? && draft?
  end

  # <<<<<<<<<<<< Wizard  <<<<<<<<<<<

  # >>>>>>>>>>>> Auction >>>>>>>>>>>
  attr_accessible :allow_auction

  has_many :bets, :dependent => :destroy, :order => 'bets.id DESC'

  default_value_for :allow_auction, false

  def price_min
    return 0 if showings.actual.empty?

    return tickets.pluck(:price).min if tickets.any?

    showings.actual.pluck(:price_min).compact.min || 0
  end
  # <<<<<<<<<<<< Auction <<<<<<<<<<<

  alias_attribute :to_s,            :title
  alias_attribute :tag_ru,          :tag
  alias_attribute :title_ru,        :title
  alias_attribute :title_translit,  :title
  alias_attribute :rating, :total_rating

  searchable :include => [
    :gallery_images,
    :gallery_social_images,
    :invitations,
    :showings,
    :addresses,
    :comments,
  ] do
    boolean :has_images, :using => :has_images?

    float :rating

    float :age_min
    float :age_max

    string :search_kind
    string :state
    string(:inviteable_categories, :multiple => true) { ::Inviteables.instance.categories_for_afisha(self) if actual? }
    string(:kind, :multiple => true) { kind.map(&:value) }

    text :title,                :boost => 1.0 * 1.2
    text :title_ru,             :boost => 1.0,        :more_like_this => true
    text :title_translit,       :boost => 0.0,                                  :stored => true
    text :original_title,       :boost => 1.5,        :more_like_this => true,  :stored => true
    text :human_model_name,     :boost => 0.5 * 1.2
    text :human_model_name_ru,  :boost => 0.5
    text :tag,                  :boost => 0.5 * 1.2
    text :tag_ru,               :boost => 0.5,        :more_like_this => true,  :stored => true
    text :place,                :boost => 0.5 * 1.2
    text :place_ru,             :boost => 0.5
    text :address,              :boost => 0.3 * 1.2
    text :address_ru,           :boost => 0.3
    text :description,          :boost => 0.1 * 1.2                                               do text_description end
    text :description_ru,       :boost => 0.1,                                  :stored => true   do text_description end

    time :last_showing_time,  :trie => true
    date :created_at

    text :title, :as => :term_text
  end

  def actual?
    self.showings.actual.any?
  end

  def search_kind
    self.class.name.underscore
  end

  def has_visit_for?(user)
    visits.where(:user_id => user).any?
  end

  def visit_for(user)
    visits.find_by_user_id(user)
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

  def likes_count
    self.votes.liked.count
  end

  def get_vk_event_id
    self.vk_event_url.split('/').last.gsub(/event/, '')
  end

  def update_rating
    update_attribute :total_rating, (copies.sold.count +
                                     0.5*visits.count +
                                     0.1*votes.liked.count +
                                     0.01*page_visits.count)
  end

  def human_model_name
    self.class.model_name.human
  end

  alias_attribute :human_model_name_ru, :human_model_name

  def self.ordered_descendants
    kind.values
  end

  def tags
    tag.to_s.split(/,\s+/).map(&:mb_chars).map(&:downcase).map(&:squish)
  end

  def address
    addresses.uniq.join(' ')
  end

  def place
    showings.pluck(:place).uniq.join(' ')
  end

  def organization
    organizations.first
  end

  alias_method :address_ru, :address
  alias_method :place_ru,   :place

  def first_showing
    showings.first
  end

  def first_showing_time
    first_showing.try(:starts_at)
  end

  def last_showing
    showings.last
  end

  def last_showing_time
    last_showing.try(:ends_at) || last_showing.try(:starts_at)
  end

  def create_showing(attributes)
    showings.create attributes
  end

  def has_tickets_for_sale?
    tickets.available.any?
  end

  def has_available_ponominalu_tickets?
    ponominalu_tickets.available.any?
  end

  def has_available_tickets?
    has_tickets_for_sale? || has_available_ponominalu_tickets? || bkz_link.present?
  end

  def max_tickets_discount
    tickets.joins(:copies).where('copies.state = ?', :for_sale).map(&:discount).sort.last
  end

  def destroy_showings
    showings.map(&:destroy)
  end

  def accounts_for_lottery
    @accounts_for_lottery ||= invitations.where('invited_id IS NOT NULL').joins(:invite_messages).where('messages.agreement = ?', 'agree').map(&:account).uniq
  end

  def has_images?
    images.any?
  end

  def images
    [gallery_images, gallery_social_images].flatten
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
    real_external_url
  end

  def build_description
    if kind.include? 'movie'
      patch = ''
      movies_properties_array.each do |value|
        code_name = value.keys.first
        civil_name = value[code_name]
        patch += "|#{civil_name}|#{self.send(code_name)}|\n" if self.send(code_name).present?
      end
      self.description = patch + self.description
    end
  end

  def rebuild_description
    table = description.scan(/^\|(.+)\|(.+)\|\n/)
    movies_properties_hash = movies_properties_array.reduce(:merge)
    table.each do |row|
      civil_name, value = row
      code_name = movies_properties_hash.find {|k, v| v == civil_name }.first
      self.send("#{code_name}=".to_sym, value) if code_name
      description.gsub!(/^\|#{Regexp.escape(civil_name)}\|.+\|\n/, '')
    end
  end

  def movies_properties_array
    [
      { year:               'год' },
      { film_created_in:    'страна' },
      { slogan:             'слоган' },
      { director:           'режиссёр' },
      { scenario:           'сценарий' },
      { producer:           'продюссер' },
      { operator:           'оператор' },
      { compositor:         'композитор' },
      { art_directors:      'художник' },
      { editors:            'монтаж' },
      { stars:              'в главных ролях' },
      { genre:              'жанр' },
      { premiere_world:     'премьера (мир)' },
      { premiere_RF:        'премьера (РФ)' },
      { age_category:       'возрастная категория' },
      { duration:           'время' }
    ]
  end

  def text_description
    @text_description ||= html_description.as_text
  end

  def self.trailer_auto_html(trailer_code)
    AutoHtml.auto_html(trailer_code) do
      youtube(:width => 580, :height => 350)
      vimeo(:width => 580, :height => 350)
      link(:target => '_blank', :rel => 'nofollow')
    end
  end

  # Afisha movie kind #
  def premiere?
    distribution_starts_on && distribution_starts_on >= Date.today.beginning_of_week && distribution_starts_on <= Date.today.end_of_week && showings.count >= 5
  end

  def movie?
    kind.include?('movie')
  end

  def reindex_showings
    showings.actual.map(&:index!)
  end

  def ignore_fields
    [ :created_at,
      :id,
      :popularity,
      :poster_image_content_type,
      :poster_image_file_name,
      :poster_image_file_size,
      :poster_image_updated_at,
      :poster_image_url,
      :slug,
      :state,
      :total_rating,
      :updated_at,
      :user_id,
      :vkontakte_likes,
      :yandex_metrika_page_views,
      :vfs_path
    ]
  end

  def change_versionable?
    self.changed? && (self.changes.keys.map(&:to_sym) - ignore_fields).any?
  end

  def save_version
    self.versions.create!(:body => self.changes.to_json(:except => ignore_fields))
  end

  def can_be_deleted?
    return false if tickets.joins(:copies).where('copies.state IN (?)', [:reserved, :sold]).any?

    return false if published?

    true
  end

  def can_be_send_to_drafts?
    return false if updated_at < Time.zone.now - 2.days

    true
  end

  # >>>>>>>>>>>> Poster to VK >>>>>>>>>>>
  def check_poster_changed?
    version = JSON.parse(self.versions.last.body) if self.versions.any?

    return true if version && version.has_key?('poster_url')

    false
  end

  def vk_client
    VkontakteApi::Client.new(User.find(9).token)
  end

  def vk_album_id(client)
    album_title = "Афиши #{I18n.l(Time.zone.today, :format => '%B-%Y')}"
    album_id = nil
    album = client.photos.get_albums(owner_id: -58652180).select{|g| g.title == album_title}

    if album.one?
      album_id = album.first.aid
    else
      album_id = create_vk_album(client)
    end

    album_id
  end

  def create_vk_album(client)
    album = client.photos.create_album(title: "Афиши #{I18n.l(Time.zone.today, :format => '%B-%Y')}", group_id: 58652180, comment_privacy: 1, privacy: 1)
    album.aid
  end

  def upload_poster_to_vk
    client = vk_client
    begin
      album_id = vk_album_id(client)
      up_serv = client.photos.get_upload_server(aid: album_id, group_id: 58652180)
      file = Tempfile.new(['afisha-poster','.jpg'])
      file.binmode
      file.write Curl.get(poster_url).body_str
      upload = VkontakteApi.upload(url: up_serv.upload_url, photo: [file.path, 'image/jpeg'])
      photo = client.photos.save(upload)
      file.close!
      photo_vk_id = "photo#{photo.first.owner_id}_#{photo.first.pid}"
      self.update_column(:poster_vk_id, photo_vk_id)
      client.photos.edit(oid: photo.first.owner_id, photo_id: photo.first.pid, caption: self.title)
    rescue
    end
  end
  # <<<<<<<<<<<< Poster to VK <<<<<<<<<<<

  private

  def afisha_schedule_attributes_blank?(attributes)
    %w[ends_at ends_on starts_at starts_on].each do |attribute|
      return false unless attributes[attribute].blank?
    end

    true
  end

  def prepare_trailer
    self.trailer_code.to_s.gsub!(/width=("|')(\d+)("|')/i, 'width="740"')
    self.trailer_code.to_s.gsub!(/height=("|')(\d+)("|')/i, 'height="450"')
  end

  def set_wmode_for_trailer
    self.trailer_code.gsub!(/(object|embed)/, '\1 wmode="opaque"') if self.trailer_code?
  end

  def self.new_afisha_url
    AfishaKind.new.send("#{Settings["app.city"]}_url")
  end
end

# == Schema Information
#
# Table name: afisha
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  description               :text
#  original_title            :string(255)
#  poster_url                :text
#  trailer_code              :text
#  tag                       :text
#  vfs_path                  :string(255)
#  image_url                 :text
#  distribution_starts_on    :datetime
#  distribution_ends_on      :datetime
#  slug                      :string(255)
#  constant                  :boolean
#  yandex_metrika_page_views :integer
#  vkontakte_likes           :integer
#  vk_aid                    :string(255)
#  yandex_fotki_url          :string(255)
#  popularity                :float
#  age_min                   :float
#  age_max                   :float
#  total_rating              :float
#  state                     :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  poster_image_url          :text
#  user_id                   :integer
#  kind                      :text
#  vk_event_url              :string(255)
#  fb_likes                  :integer
#  odn_likes                 :integer
#  allow_auction             :boolean
#  poster_vk_id              :string(255)
#  promoted_at               :datetime
#  bkz_link                  :text
#

