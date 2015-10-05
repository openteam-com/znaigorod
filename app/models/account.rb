# encoding: utf-8

class Account < ActiveRecord::Base
  extend Enumerize

  include CropedPoster

  attr_accessor :poster_image_url, :poster_image_content_type

  alias_attribute :file_url, :avatar_url
  alias_attribute :to_s,     :title

  attr_accessible :avatar, :birthday, :email, :badge,
                  :first_name, :gender, :last_name, :patronymic,
                  :rating, :nickname, :location,
                  :account_settings_attributes,
                  :poster_image_url

  has_many :discounts,            :dependent => :destroy
  has_many :feeds,                :dependent => :destroy, :order => 'created_at DESC'
  has_many :friends,              :dependent => :destroy
  has_many :gallery_images,       :dependent => :destroy, :as => :attachable
  has_many :invitations,          :dependent => :destroy
  has_many :members,              :dependent => :destroy
  has_many :questions,            :dependent => :destroy
  has_many :received_invitations, :dependent => :destroy, :class_name => 'Invitation', :foreign_key => :invited_id
  has_many :reviews,              :dependent => :destroy, :order => 'updated_at DESC'
  has_many :users,                :dependent => :destroy, :order => 'id ASC'
  has_many :works,                :dependent => :destroy


  # STI
  has_many :messages, :dependent => :destroy, :order => 'messages.created_at DESC'
  has_many :notification_messages,            :order => 'messages.created_at DESC'
  has_many :private_messages,                 :order => 'messages.created_at DESC'
  has_many :produced_messages, :as => :producer, :class_name => 'PrivateMessage'

  has_many :afisha,                   :through => :users
  has_many :comments,                 :through => :users,                :order => 'comments.created_at DESC'
  has_many :events,                   :through => :users,                :order => 'afisha.created_at DESC'
  has_many :invite_messages,          :through => :invitations,          :order => 'messages.created_at DESC'
  has_many :page_visits,              :through => :users
  has_many :payments,                 :through => :users
  has_many :received_invite_messages, :through => :received_invitations, :order => 'messages.created_at DESC', :source => :invite_messages
  has_many :roles,                    :through => :users
  has_many :showings,                 :through => :users
  has_many :visits,                   :through => :users,                :order => 'visits.created_at DESC'
  has_many :votes,                    :through => :users,                :order => 'votes.id DESC'

  has_many :friendable,      :as => :friendable,     :class_name => 'Friend'
  has_many :my_page_visits,  :as => :page_visitable, :class_name => 'PageVisit'

  has_one :account_settings, :dependent => :destroy
  accepts_nested_attributes_for :account_settings

  after_create :get_social_avatar, :create_account_settings

  before_destroy :remove_private_messages, :remove_friendable, :remove_comments

  scope :dating,                  -> { account_settings.dating? }
  scope :females,                 -> { where :gender => 'female' }
  scope :males,                   -> { where :gender => 'male' }
  scope :ordered,                 -> { order 'id ASC' }
  scope :with_email,              -> { where "email IS NOT NULL AND email != ''" }
  scope :with_personal_digest,    -> { includes(:account_settings).where('account_settings.personal_digest = ?', true) }
  scope :with_public_invitations, -> { joins(:invitations).group('accounts.id, invitations.invited_id').having('COUNT(invitations.id) > ? AND invitations.invited_id IS NULL', 0) }
  scope :with_rating,             -> { where('rating IS NOT NULL') }
  scope :with_site_digest,        -> { includes(:account_settings).where('account_settings.site_digest = ?', true) }
  scope :with_statistics_digest,  -> { includes(:account_settings).where('account_settings.statistics_digest = ?', true) }
  scope :actual, -> { where('last_visit_at >= ? and last_visit_at <= ?', Time.zone.now - 1.month, Time.zone.now) }

  serialize :badge, Array
  enumerize :badge, :in => [:photo_correspondent], :multiple => true, :predicates => true
  enumerize :gender, :in => [:undefined, :male, :female], :default => :undefined, :predicates => true

  normalize_attribute :email, :with => [:strip, :blank]
  validates_email_format_of :email, :allow_nil => true

  has_croped_poster min_width: 200, min_height: 200

  has_attached_file :avatar, :storage => :elvfs, :elvfs_url => Settings['storage.url'], :default_url => :resolve_default_avatar_url

  searchable do
    boolean(:dating)      { account_settings.dating? }
    boolean(:with_avatar) { with_avatar? }

    float :rating,   :trie => true

    integer(:friendable) { my_page_visits.count + received_invitations.count }

    string :gender
    string :search_kind
    string(:acts_as, :multiple => true)            { acts_as }
    string(:friend_ids, :multiple => true)         { friendable }
    string(:invited_categories, :multiple => true) { invitations.invited.with_categories.select(&:actual?).flat_map(&:categories).uniq }
    string(:inviter_categories, :multiple => true) { invitations.inviter.with_categories.select(&:actual?).flat_map(&:categories).uniq }
    string(:kind, :multiple => true)               { indexing_kinds }

    text :first_name
    text :last_name
    text :location
    text :nickname
    text :patronymic
    text :title, :as => :term_text
    text :title, :stored => true

    time :created_at, :trie => true
  end

  Role.role.values.each do |role|
    define_method "is_#{role}?" do
      self.class.where(:id => id).joins(:roles).where('roles.role = ?', role).any?
    end
  end

  def limit_is_reached?
    invitations.where('created_at > ?', DateTime.now - 1.day).count >= 10
  end

  def remove_comments
    self.comments.each do |c|
      unless c.child.present?
        c.destroy
      else
        c.user_id = nil
        c.save!
      end
    end
  end

  def remove_private_messages
    PrivateMessage.where(:producer_id => self.id).each do |m|
      m.destroy
    end
  end

  def remove_friendable
    Friend.where(:friendable_id => self.id).each do |f|
      f.destroy
    end
  end

  def create_account_settings
    self.account_settings = AccountSettings.new
    self.save!
  end

  def with_avatar?
    ![
      "#{Settings['storage.url']}/files/44240/200-200/default_female_avatar.png",
      "#{Settings['storage.url']}/files/44241/200-200/default_male_avatar.png",
      "#{Settings['storage.url']}/files/44242/200-200/default_undefined_avatar.png",
      "#{Settings['storage.url']}/files/28694/200-200/default_avatar.png"
    ].include?(avatar.url)
  end

  def resolve_default_avatar_url
    return "#{Settings['storage.url']}/files/44240/200-200/default_female_avatar.png"    if gender.female?
    return "#{Settings['storage.url']}/files/44241/200-200/default_male_avatar.png"      if gender.male?
    return "#{Settings['storage.url']}/files/44242/200-200/default_undefined_avatar.png" if gender.undefined?

    "#{Settings['storage.url']}/files/28694/200-200/default_avatar.png"
  end

  def friends_feeds(search)
    friends = self.friends.includes(:friendable => { :feeds => :feedable })
    feeds = [nil]
    friends.each do |friend|
      if friend.friendly?
        if search[:type_of_feedable] == 'discount'
          feeds = feeds.concat(friend.friendable.feeds.discount_or_member)
        else
          feeds = feeds.concat(friend.friendable.feeds.where(search))
        end
      end
    end
    feeds.compact!

    unless feeds.blank?
      feeds = feeds.sort_by(&:created_at).reverse
    end

    feeds
  end

  def friends_count
    self.friends.where(:friendly => true).count
  end

  def images_count
    self.gallery_images.count
  end

  def age
    now = Time.zone.now.to_date
    age = now.year - self.birthday.year - ((now.month > self.birthday.month || (now.month == self.birthday.month && now.day >= self.birthday.day)) ? 0 : 1)
    I18n.t('account.age', :count => age)
  end

  def create_page_visit(session, user_agent, user)
    my_page_visit = self.my_page_visits.new
    my_page_visit.user_agent = user_agent.to_s.encode('UTF-8', :undef => :replace, :invalid => :replace, :replace => '')
    my_page_visit.user = user
    my_page_visit.save
  end

  def sended_invite_message(messageable, account_id, invite)
    self.invite_messages.where(messageable_id: messageable.id,
                                 messageable_type: messageable.class.name,
                                 account_id: account_id,
                                 invite_kind: invite).any?
  end

  def indexing_kinds
    array = roles.map(&:role)
    array << 'afisha_editor' if afisha.published.any?
    array
  end

  def search_kind
    self.class.name.underscore
  end

  def acts_as
    invitations.without_invited.select(&:actual?).map(&:kind).uniq
  end

  def title
    "#{first_name} #{last_name}".gsub(/\s$/,'')
  end

  def get_vkontakte_friends(user)
    vk_client = VkontakteApi::Client.new

    begin
      uids = vk_client.friends.get(user_id: user.uid)

      uids.each do |uid|
        if User.vkontakte.where(uid: uid.to_s).any?
          self.friends.create(friendable: get_account(uid.to_s), friendly: true) unless self.friends_with?(get_account(uid.to_s))
        end
      end
    rescue
    end
  end

  def get_facebook_friends(user)
    fb_client = Koala::Facebook::API.new(user.token)
    begin
      friends = fb_client.get_connections(user.uid, "friends")
      friends.each do |friend|
        if User.facebook.where(uid: friend['id']).any?
          self.friends.create(friendable: get_account(friend['id']), friendly: true) unless self.friends_with?(get_account(friend['id']))
        end
      end
    rescue
    end
  end

  def get_social_avatar
    begin
      user = users.first
      vk_client = VkontakteApi::Client.new
      fb_client = Koala::Facebook::API.new
      image_url = case user.provider
                  when 'vkontakte'
                    vk_client.users.get(uid: user.uid,
                                        fields: :photo_200_orig).first.photo_200_orig
                  when 'facebook'
                    fb_client.get_picture(user.uid, type: 'large')
                  when 'google_oauth2', 'twitter'
                    user.social_avatar_url
                  end
      set_avatar_from_url(image_url) if image_url
    rescue
    end
  end

  def set_avatar_from_url(url)
    self.avatar = URI.parse(url)
    save!
  end

  def get_account(uid)
    User.find_by_uid(uid).account
  end

  def link_to_social
    link = ''
    auth = users.first.auth_raw_info
    return link if auth.blank? || auth.is_a?(String)
    ["Facebook", "Mailru", "Odnoklassniki", "Twitter", "Vkontakte", "GoogleOauth2"].each do |provider|
      link = auth.try(:extra).try(:raw_info).try(:link) if provider == "GoogleOauth2" && auth.try(:extra).try(:raw_info).try(:link).present?
      link = auth.info.urls.send(provider) if auth.info.urls.respond_to?(provider)
    end
    link = "#{link}id#{auth.uid}" if link == 'http://vk.com/'

    link
  end

  def provider
    users.first.provider
  end

  def update_rating
    update_attribute(:rating,
                     0.5 * payments.approved.where(:type=>'CopyPayment').map(&:copies).flatten.count +
                     0.25 * afisha.count +
                     0.1 * comments.count +
                     0.1 * visits.count +
                     0.01 * votes.liked.count +
                     0.01 * page_visits.count +
                     0.01 * my_page_visits.count)
  end

  def friendly_for(account)
    self.friends.where(friendable_id: account.id)
  end

  def friends_with?(account)
    self.friends.where(friendable_id: account.id, friendly: true).any?
  end

  def friendable
    Friend.where(:friendable_id => self.id).pluck(:account_id)
  end

  def dialogs
    dialogs = (PrivateMessage.to(self).includes(&:producer) + PrivateMessage.from(self).includes(&:account))
      .sort_by { |t| - t.created_at.to_i }

    [].tap { |array|
      dialogs.each do |dialog|
        account = dialog.producer_id == self.id ? dialog.account : dialog.producer

        array << account
      end
    }.uniq
  end

  def invitation_for(account, kind, category, inviteable)
    relation = invitations.send(kind)
      .where(:invited_id => account.id)
      .joins(:invite_messages).where('messages.agreement IS NULL')

    relation = relation.where(:category => category) if category.present?
    relation = relation.where(:inviteable_id => inviteable.id, :inviteable_type => inviteable.class.name) if inviteable

    relation.first
  end

  def invitation_without_invited_for(inviteable, kind)
    invitations.send(kind).where(:invited_id => nil)
      .where(:inviteable_id => inviteable.id, :inviteable_type => inviteable.class.name).first
  end

  def reacts_to?(invitation)
    relation = invitations.send(invitation.opposite_kind).where(:invited_id => invitation.account.id)
    relation = relation.where(:inviteable_type => invitation.inviteable.class.name, :inviteable_id => invitation.inviteable.id) if invitation.inviteable
    relation = relation.where(:category => invitation.category).where(:inviteable_type => nil) if invitation.category.present?

    relation.any?
  end

  # avatar stuff
  def poster_image_url?
    true
  end

  def poster_url=(poster_url)
    self.avatar_url = poster_url
  end

  def has_email?
    email.present?
  end

  def sled_rating
    @sled_rating ||= reviews.published.count + sled_comments * 0.5 + sled_votes * 0.2 + sled_page_visits * 0.1
  end

  def sled_comments
    @sled_comments ||= reviews.published.joins(:comments).count
  end

  def sled_votes
    @sled_votes ||= reviews.published.joins(:votes).where("votes.like =?",true).count
  end

  def sled_page_visits
    @sled_page_visits ||= reviews.published.joins(:page_visits).count
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id                  :integer          not null, primary key
#  first_name          :string(255)
#  last_name           :string(255)
#  patronymic          :string(255)
#  email               :string(255)
#  rating              :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  nickname            :string(255)
#  location            :string(255)
#  gender              :string(255)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  avatar_url          :text
#  birthday            :date
#  last_visit_at       :datetime
#  badge               :text
#

