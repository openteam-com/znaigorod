class Room < ActiveRecord::Base
  include HasVirtualTour

  belongs_to :context, :polymorphic => true

  attr_accessible :capacity, :context_id, :context_type, :description, :feature, :rooms_count, :title, :prices_attributes

  has_many :prices, :as => :context, :class_name => 'DailyPrice', :dependent => :destroy
  has_many :gallery_images, :as => :attachable,  :dependent => :destroy

  accepts_nested_attributes_for :prices, :allow_destroy => true

  validates_presence_of :capacity, :feature, :rooms_count, :title

  include PresentsAsCheckboxes

  presents_as_checkboxes :feature

  searchable do
    integer :price_min
    integer :price_max
    integer :capacity
    integer :rooms_count

    string :categories,    :multiple => true
    string :context_id
    string :room_features, :multiple => true

    text(:title, :boost => 1.0 * 1.2)     { context.organization.title }
    text(:title_ru, :boost => 1.0)        { context.organization.title }
    text(:title_translit, :boost => 0.0)  { context.organization.title }

    string(:context_type)                                   { context_type.underscore }
    string(:features, :multiple => true)                    { context_features }
    string(:offers,   :multiple => true)                    { context_offers }
    string(:status)                                         { context.organization.status }
    string(:organization_category_slugs, :multiple => true) { context.organization.organization_category_uniq_slugs }
  end

  def price_min
    prices.pluck(:value).min
  end

  def price_max
    prices.pluck(:max_value).compact.max
  end

  private

  def categories
    context.categories.map(&:mb_chars).map(&:downcase).map(&:to_s)
  end

  def room_features
    features.map(&:mb_chars).map(&:downcase).map(&:to_s)
  end

  def context_features
    context.features.map(&:mb_chars).map(&:downcase).map(&:to_s)
  end

  def context_offers
    context.offers.map(&:mb_chars).map(&:downcase).map(&:to_s)
  end
end

# == Schema Information
#
# Table name: rooms
#
#  id           :integer          not null, primary key
#  context_id   :integer
#  context_type :string(255)
#  title        :string(255)
#  capacity     :integer
#  rooms_count  :integer
#  description  :text
#  feature      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

