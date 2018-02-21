class MainPageReview < ActiveRecord::Base
  attr_accessible :position, :review_id, :expires_at

  belongs_to :review

  scope :ordered, -> { order :position }
  scope :actual, -> { where 'expires_at > ?', Time.zone.now }
  scope :with_reviews, -> { where 'review_id IS NOT NULL' }

  scope :used, -> { actual.with_reviews.ordered }

  validates :expires_at, :review_id, :presence => true

  before_create :set_position

  after_destroy :reorder_positions

  def self.latest_reviews
    search = Review.search do
      order_by :created_at, :desc
      paginate :page => 1, :per_page => 3
      with :state, :published
      without used.map(&:review)
      without :type, :question
      without :category, [:adv_plus, :megapolis, :inform]
    end

    search.results
  end

  private

  def set_position
    self.position = MainPageReview.maximum(:position).to_i + 1
  end

  def reorder_positions
    MainPageReview.ordered.each_with_index do |item, index|
      item.update_attribute :position, index + 1
    end
  end
end

# == Schema Information
#
# Table name: main_page_reviews
#
#  id         :integer          not null, primary key
#  review_id  :integer
#  position   :integer
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

