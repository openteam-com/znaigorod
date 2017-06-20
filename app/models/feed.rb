class Feed < ActiveRecord::Base
  attr_accessible :feedable, :account, :created_at, :updated_at
  belongs_to :feedable, :polymorphic => true
  belongs_to :account
  after_create :set_type_of_feedable

  scope :discount_or_member,  -> {where("feedable_type = 'Member' OR feedable_type = 'Discount'")}

  def self.feeds_for_presenter(searcher_params)
    if searcher_params[:type_of_feedable] == 'discount'
      searcher_params.delete(:type_of_feedable)
      self.discount_or_member.where(searcher_params).includes(:feedable).order('created_at DESC')
    else
      self.where(searcher_params).includes(:feedable).order('created_at DESC')
    end
  end

  def set_type_of_feedable
    feedable_types = Feed.pluck(:feedable_type).uniq - ['Review','Comment']
    review_types = ['review_article', 'review_photo', 'review_video']

    self.type_of_feedable = self.feedable_type.underscore if feedable_types.include? self.feedable_type
    if self.feedable_type == 'Review'
      self.type_of_feedable = self.feedable.class.name.underscore
      self.type_of_feedable = 'review' if review_types.include? self.type_of_feedable
    end
    self.type_of_feedable = self.feedable.is_answer? ? 'question' : 'comment' if self.feedable_type == 'Comment'

    self.save
  rescue
  end
end

# == Schema Information
#
# Table name: feeds
#
#  id               :integer          not null, primary key
#  feedable_id      :integer
#  feedable_type    :string(255)
#  account_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  type_of_feedable :string(255)
#

