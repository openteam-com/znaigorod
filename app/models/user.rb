# encoding: utf-8

class User < ActiveRecord::Base
  attr_accessible :uid, :provider, :auth_raw_info, :roles_attributes, :account

  devise :trackable, :omniauthable, :rememberable,
    omniauth_providers: [:vkontakte, :google_oauth2, :yandex, :facebook, :twitter, :odnoklassniki, :mailru]

  has_many :afisha,          uniq: true
  has_many :showings,        through: :afisha
  has_many :activities,      dependent: :destroy
  has_many :comments,        order: 'comments.created_at DESC'
  has_many :organization_managers
  has_many :managed_organizations, through: :organization_managers, :source => :organization
  has_many :comments_images, :dependent => :destroy, :conditions => { :attachable_type => 'Comment' }
  has_many :organizations
  has_many :roles,           dependent: :destroy
  has_many :votes,           dependent: :destroy
  has_many :visits,          dependent: :destroy
  has_many :page_visits
  has_many :payments
  has_many :events, :class_name => 'Afisha'
  has_many :map_placemarks
  has_many :make_their_organization_requests

  belongs_to :account

  serialize :auth_raw_info

  validates_presence_of :provider, :uid

  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: :all_blank

  scope :with_role,      ->(role) { joins(:roles).where('roles.role = ?', role) }
  scope :sales_managers, -> { with_role(:sales_manager) }
  scope :vkontakte,      -> { where(provider: 'vkontakte') }
  scope :facebook,       -> { where(provider: 'facebook') }
  scope :ordered,        -> { order('ID ASC') }

  after_create :create_account
  after_save :update_email

  def review_manager?
    roles.where(:role => 'review_manager').present?
  end

  def update_email
    if self.account.email.blank? && self.email.present?
      self.account.email = self.email
      self.account.save!
    end
  end

  def self.find_or_create_by_oauth(auth_raw_info)
    provider, uid = auth_raw_info.provider, auth_raw_info.uid.to_s

    user = find_or_initialize_by_provider_and_uid(provider.squish, uid.squish)
    user.auth_raw_info = auth_raw_info
    user.save!

    user
  end

  def token
    return '' if auth_raw_info.is_a?(String)
    auth_raw_info.try(:credentials).try(:token)
  end

  searchable do
    text :name
  end

  def name
    return 'Mister X' if auth_raw_info.is_a?(String)
    auth_raw_info.try(:info).try(:name) || 'Mister X'
  end

  def nickname
    return '' if auth_raw_info.is_a?(String)
    auth_raw_info.try(:info).try(:nickname)
  end

  def gender
    return '' if auth_raw_info.is_a?(String)
    user_gender = (auth_raw_info.try(:extra).try(:raw_info).try(:gender) || auth_raw_info.try(:extra).try(:raw_info).try(:sex))
    gender =  case user_gender
              when 1 || 'female'
                gender = :female
              when 2 || 'male'
                gender = :male
              else
                gender = :undefined
              end
  end

  def email
    return '' if auth_raw_info.is_a?(String)
    # for facebook, mailru
    result = auth_raw_info.try(:extra).try(:raw_info).try(:email)
    # for yandex and google
    result = auth_raw_info.try(:info).try(:email) if result.nil?

    result
  end

  def location
    return '' if auth_raw_info.is_a?(String)
    auth_raw_info.try(:info).try(:location)
  end

  alias_attribute :to_s, :name

  def remember_me
    true
  end

  def vote_for(voteable)
    voteable.votes.where(:user_id => self.id)
  end

  def voted?(voteable)
    vote_for(voteable).one?
  end

  def liked?(voteable)
    voted?(voteable) && vote_for(voteable).first.like?
  end

  def social_avatar_url
    case provider
    when 'google_oauth2'
      auth_raw_info.try(:[], :info).try(:[], :image)
    when 'facebook'
      auth_raw_info.try(:[], :info).try(:[], :image)
    when 'vkontakte'
      auth_raw_info.try(:[], :extra).try(:[], :raw_info).try(:[], :photo_big)
    when 'twitter'
      link = auth_raw_info.try(:[], :info).try(:[], :image)
      link.gsub(/_normal/,'') if link
    else
      Settings['app.default_avatar_url']
    end
  end

  def profile
    case provider
    when 'vkontakte', 'facebook', 'twitter', 'odnoklassniki', 'mailru'
      auth_raw_info[:info][:urls][provider.capitalize.to_sym]
    when 'google_oauth2'
      auth_raw_info[:extra][:raw_info][:link]
    else
      nil
    end
  end

  Role.role.values.each do |value|
    define_method "is_#{value}?" do
      roles.pluck(:role).include?(value)
    end
  end

  def manager_of?(organization)
    is_sales_manager? && organization.manager == self
  end


  def create_account
    name = self.name.split(' ')
    account = Account.new(first_name: name.first, last_name: (name.last if name.count > 1),
                             nickname: self.nickname, location: self.location,
                             email: self.email, gender: self.gender)
    account.users = [self]
    account.save!
    update_attributes(account: account)
  end

  def vk_uid
    return nil unless provider == 'vkontakte'
    uid
  end

  def get_friends_from_socials
    method = "get_#{provider}_friends"
    account.send(method, self) if account.respond_to?(method)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  roles_mask          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  uid                 :string(255)
#  sign_in_count       :integer          default(0)
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :string(255)
#  last_sign_in_ip     :string(255)
#  provider            :string(255)
#  auth_raw_info       :text
#  remember_created_at :datetime
#  remember_token      :string(255)
#  rating              :string(255)
#  account_id          :integer
#

