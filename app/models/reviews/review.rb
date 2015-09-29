class Review < ActiveRecord::Base
  extend Enumerize
  extend FriendlyId

  include Album::Downloader
  include CropedPoster
  include DraftPublishedStates
  include MakePageVisit
  include VkUpload

  attr_accessor :related_items, :tagit_categories, :need_change, :category_flag

  alias_attribute :file_url,       :poster_image_url
  alias_attribute :description,    :content
  alias_attribute :description_ru, :content
  alias_attribute :title_ru,       :title

  before_save :set_poster

  before_save :store_cached_content_for_index
  before_save :store_cached_content_for_show

  before_save :set_allow_external_links # for inform category

  before_validation :set_categories, :if => :category_flag

  after_save :parse_related_items, :if => :need_change

  attr_accessible :content, :title, :tag, :categories,
                  :allow_external_links, :only_tomsk,
                  :related_items, :tagit_categories, :need_change, :category_flag,
                  :organization_category_ids

  belongs_to :account
  belongs_to :contest
  belongs_to :afisha
  belongs_to :organization

  has_many :review_category_items, :dependent => :destroy
  has_many :organization_categories, :through => :review_category_items

  has_many :all_images,            :as => :attachable, :class_name => 'Attachment', :conditions => { :type => %w[GalleryImage GallerySocialImage] }
  has_many :comments,              :as => :commentable,    :dependent => :destroy
  has_many :gallery_images,        :as => :attachable,     :dependent => :destroy
  has_many :gallery_social_images, :as => :attachable,     :dependent => :destroy
  has_many :messages,              :as => :messageable,    :dependent => :destroy
  has_many :page_visits,           :as => :page_visitable, :dependent => :destroy
  has_many :relations,             :as => :master,         :dependent => :destroy
  has_many :votes,                 :as => :voteable,       :dependent => :destroy
  has_many :webanketas,            :as => :context,        :dependent => :destroy

  has_many :afishas,        :through => :relations, :source => :slave, :source_type => Afisha
  has_many :organizations,  :through => :relations, :source => :slave, :source_type => Organization
  has_many :reviews,        :through => :relations, :source => :slave, :source_type => Review
  has_many :photogalleries, :through => :relations, :source => :slave, :source_type => Photogallery
  has_many :users,          :through => :account

  has_one  :feed, :as => :feedable, :dependent => :destroy

  serialize :categories, Array

  scope :by_state,          -> (state) { where :state => state }
  scope :draft,             -> { where :state => :draft }
  scope :published,         -> { where :state => :published }
  scope :without_questions, -> { where "type != 'Question'" }
  scope :ordered,           order('created_at desc')
  scope :with_period,       -> { where created_at: (Time.zone.now - 1.month)..Time.zone.now }

  validates_presence_of :title, :categories

  default_value_for :allow_external_links, false
  default_value_for :only_tomsk,           false

  enumerize :categories,
    :in => [:newyear, :children, :interesting, :auto, :accidents, :crash, :animals, :cookery,
            :eighteen_plus, :humor, :hi_tech, :entertainment, :family, :lifehack,
            :economy, :complaints_book, :spirituality, :help, :men_and_women, :creation,
            :handmade, :boiling, :good_news, :health, :sport, :policy, :studies, :abiturient,
            :commercial, :other, :adv_plus, :megapolis, :inform],
    :multiple => true,
    :predicates => true

  friendly_id :title, :use => :slugged

  alias :old_normalize_friendly_id :normalize_friendly_id
  def normalize_friendly_id(string)
    I18n.l(created_at, :format => '%Y-%m') + '/' + old_normalize_friendly_id(string)
  end

  has_croped_poster min_width: 353, min_height: 199, :default_url => 'public/post_poster_stub.jpg'

  normalize_attribute :title, :with => [:strip, :squish]
  normalize_attribute :categories, :with => :blank_array

  searchable do
    boolean :only_tomsk

    float :rating

    integer(:commented) { comments.size }

    string :state
    string(:category, :multiple => true) { categories.map(&:value) }
    string(:search_kind) { 'review' }
    string(:type) { useful_type }

    text :content,        :boost => 0.1 * 1.2
    text :description_ru, :boost => 0.1, :more_like_this => true, :stored => true
    text :title,          :boost => 1.0, :more_like_this => true, :stored => true
    text :title_ru,       :boost => 1.0, :more_like_this => true

    text :title,          :as => :term_text

    time :created_at, :trie => true
  end

  def likes_count
    self.votes.liked.count
  end

  def self.descendant_names
    descendants.map(&:name).map(&:underscore) - ['question']
  end

  def self.descendant_names_without_prefix
    descendant_names.map { |name| name.gsub prefix, '' }
  end

  def useful_type
    self.class.name.underscore.gsub self.class.prefix, ''
  end

  def should_generate_new_friendly_id?
    return true if !self.slug? && self.published?

    false
  end

  def ready_for_publication?
    true
  end

  def update_rating
    update_attribute :rating, 0.5 * comments.count + 0.1 * votes.liked.count + 0.01 * page_visits.count
  end

  def has_poster?
    !!(image_url)
  end

  def user
    users.first
  end

  private

  def self.prefix
    'review_'
  end

  def set_poster
    true
  end

  def parse_related_items
    relations.destroy_all if related_items.nil?
    return true unless related_items
    relations.destroy_all

    related_items.each do |item|
      slave_type, slave_id = item.split("_")
      if slave_type == 'review'
        relation = Review.find(slave_id).relations.new
        relation.slave_type = "Review"
        relation.slave_id = id
        relation.save
      end
      relation = relations.new
      relation.slave_type = slave_type.classify
      relation.slave_id = slave_id

      relation.save
    end
  end

  def store_cached_content_for_index
    self.cached_content_for_index = is_a?(ReviewVideo) ?
      AutoHtmlRenderer.new(video_url).render_index + AutoHtmlRenderer.new(content).render_index :
      AutoHtmlRenderer.new(content).render_index
  end

  def store_cached_content_for_show
    self.cached_content_for_show = is_a?(ReviewVideo) ?
      AutoHtmlRenderer.new(video_url).render_show + AutoHtmlRenderer.new(content, allow_external_links: allow_external_links).render_show :
      AutoHtmlRenderer.new(content, allow_external_links: allow_external_links).render_show
  end

  # overrides VkUpload.image_url
  def image_url
    return poster_url if poster_url?
    return poster_image_url if poster_image_url?
    return gallery_images.first.file_url if gallery_images.any?
    return gallery_social_images.first.file_url if gallery_social_images.any?
  end

  def set_categories
    reverted_options = Hash[self.class.categories.options].inject({}) { |h, e| h[e.first.mb_chars.downcase.to_s] = e.last; h }
    form_categories = tagit_categories.split(',').map(&:squish).map(&:mb_chars).map(&:downcase).map(&:to_s)

    self.categories = form_categories.map { |e| reverted_options[e] }.compact
  end

  def set_allow_external_links
    if categories.to_a.include?('inform')
      self.allow_external_links = true
    end
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

