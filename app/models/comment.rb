# encoding: utf-8

class Comment < ActiveRecord::Base
  attr_accessible :ancestry, :body, :parent_id, :comments_images_attributes

  belongs_to :user
  has_one    :account,     :through => :user
  belongs_to :commentable, :polymorphic => true

  has_ancestry
  has_many  :votes,           :as => :voteable,    :dependent => :destroy
  has_many  :messages,        :as => :messageable, :dependent => :destroy
  has_one   :feed,            :as => :feedable,    :dependent => :destroy
  has_many  :comments_images, :as => :attachable,  :dependent => :destroy
  has_many  :reviews
  has_many  :photogalleries

  after_create :send_new_comment, :if => :organization?

  accepts_nested_attributes_for :comments_images

  scope :rendereable,  -> { where(:commentable_type => ['Afisha', 'Organization']) }

  validate :validate_comments_images

  def child
    Comment.where(:ancestry => self.id.to_s)
  end

  def is_answer?
    commentable.is_a?(Question) && is_root?
  end

  normalize_attribute :body, :ancestry
  validates_presence_of :body
  validate :authenticated_user

  def name
    user ? account.title : 'неизвестный автор'
  end

  def avatar
    user ?  account.avatar : Account.new.avatar
  end

  auto_html_for :body do
    html_escape
    simple_format
    znaigorod_link :target => "_blank", :rel => 'nofollow'
    external_links_attributes
    external_links_redirect
  end

  def organization?
    commentable.is_a? Organization && commentable.email?
  end

  def send_new_comment
    OrganizationMailer.delay(:queue => :mailer, :retry => false).new_comment(self)
  end

  private
    def authenticated_user
      errors.add :body, 'Комментарии могут оставлять только зарегистрированные пользователи' if user.nil?
    end

    def validate_comments_images
      errors.add(:comments_images, 'Можно загрузить не больше 5 картинок') if comments_images.size > 5
    end
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  commentable_id   :integer
#  commentable_type :string(255)
#  body             :text
#  ancestry         :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

