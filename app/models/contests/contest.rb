# encoding: utf-8

class Contest < ActiveRecord::Base
  extend FriendlyId

  attr_accessor :contest_type

  attr_accessible :agreement, :title, :description, :ends_at, :starts_at, :vote_type,
                  :participation_ends_at, :vfs_path, :og_description, :og_image, :contest_type,
                  :sms_prefix, :short_number, :sms_secret, :default_sort, :new_work_text, :placeholder,
                  :anketa_content, :email

  has_many :works, :as => :context, :dependent => :destroy
  has_many :accounts, :through => :works, :uniq => true
  has_many :reviews

  validates_presence_of :title, :starts_at, :ends_at, :participation_ends_at, :vote_type, :contest_type

  scope :available, -> { where('starts_at <= ?', Time.zone.now).order('starts_at desc') }

  default_scope order('id DESC')

  friendly_id :title, use: :slugged

  has_attached_file :og_image, :storage => :elvfs, :elvfs_url => Settings['storage.url']

  validates_attachment :og_image, :content_type => {
    :content_type => ['image/jpeg', 'image/jpg', 'image/png'],
    :message => 'Изображение должно быть в формате jpeg, jpg или png'
  }

  alias_attribute :title_ru,       :title
  alias_attribute :title_translit, :title

  extend Enumerize
  enumerize :contest_type, :in => [:contest_photo, :contest_video],
                   :predicates => true

  enumerize :vote_type, :in => [:like, :sms],
                   :predicates => true

  enumerize :default_sort, :in => [:by_id, :by_sms_counter, :by_zg_likes],
                   :predicates => true

  searchable do
    text :title,          :boost => 1.0 * 1.2
    text :title_ru,       :boost => 1.0,        :more_like_this => true
    text :title_translit, :boost => 0.0,        :stored => true

    string(:state) { :published }
  end

  def vote_sort_value
    vote_type.like? ? 'by_zg_likes' : 'by_sms_counter'
  end

  def self.generate_vfs_path
    "/znaigorod/contests/#{Time.now.strftime('%Y/%m/%d/%H-%M')}-#{SecureRandom.hex(4)}"
  end

  def prefix
    'contest_'
  end

  def self.descendant_names
    descendants.map(&:name).map(&:underscore)
  end

  def self.descendant_names_without_prefix
    descendant_names.map { |name| name.gsub prefix, '' }
  end

  def actual?
    ends_at > Time.zone.now && starts_at < Time.zone.now
  end

  def available_participation?
    participation_ends_at > Time.zone.now && starts_at < Time.zone.now
  end

  def type_without_prefix
    self.class.name.underscore.gsub prefix, ''
  end
end

# == Schema Information
#
# Table name: contests
#
#  id                    :integer          not null, primary key
#  title                 :string(255)
#  description           :text
#  starts_at             :datetime
#  ends_at               :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  vfs_path              :string(255)
#  slug                  :string(255)
#  og_description        :text
#  og_image_file_name    :string(255)
#  og_image_content_type :string(255)
#  og_image_file_size    :integer
#  og_image_updated_at   :datetime
#  og_image_url          :text
#  agreement             :text
#  participation_ends_at :datetime
#  type                  :string(255)
#  vote_type             :string(255)
#  sms_prefix            :string(255)
#  short_number          :integer
#  sms_secret            :string(255)
#  default_sort          :string(255)      default("by_id")
#  new_work_text         :string(255)      default("Добавить фотографию")
#  placeholder           :text
#

