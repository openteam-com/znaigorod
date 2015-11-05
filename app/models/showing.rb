# encoding: utf-8

class Showing < ActiveRecord::Base
  attr_accessible :ends_at, :hall, :place, :price_max, :price_min, :starts_at, :organization_id, :latitude, :longitude, :afisha_id

  belongs_to :afisha
  belongs_to :organization

  validates_presence_of :place, :starts_at

  delegate :distribution_starts_on, :rating, :tags, :title, :age_min, :age_max, :state, :has_tickets_for_sale?, :has_available_tickets?,
    :to => :afisha,
    :prefix => true

  delegate :address, :title, :to => :organization, :prefix => true, :allow_nil => true

  scope :actual, -> { where('showings.starts_at >= ? OR (showings.ends_at is not null AND showings.ends_at > ?)', DateTime.now.beginning_of_day, Time.zone.now) }

  scope :with_organization, where('organization_id IS NOT NULL')

  default_value_for :price_max, nil
  default_value_for :price_min, nil

  searchable :include => [
    :afisha,
    :organization,
  ] do
    date :starts_on

    float :afisha_rating

    integer :afisha_id
    integer :organization_id
    integer :price_max
    integer :price_min
    float(:age_max) { afisha_age_max }
    float(:age_min) { afisha_age_min }
    integer(:ends_at_hour) { ends_at.try(:hour) }
    integer(:organization_ids, :multiple => true) { [organization_id] if organization_id? }
    integer(:starts_at_hour) { starts_at.hour }

    latlon(:location) { Sunspot::Util::Coordinates.new(get_latitude, get_longitude) }

    string :afisha_state
    string(:afisha_category) { afisha.kind }
    string(:afisha_id_str) { afisha_id.to_s }
    string(:categories, :multiple => true) { [afisha.kind].flatten }
    string(:tags, :multiple => true) { afisha_tags.delete_if(&:blank?) }

    text :afisha_title
    text :organization_title
    text :place

    time :afisha_created_at, :trie => true
    time :afisha_distribution_starts_on, :trie => true
    time :ends_at
    time :starts_at, :trie => true

    boolean(:has_tickets) { actual? && afisha_has_available_tickets? }
  end

  def afisha_created_at
    afisha.promoted_at || afisha.created_at
  end

  def actual?
    starts_at >= Time.zone.now.beginning_of_day || (ends_at? && ends_at >= Time.zone.now.beginning_of_day)
  end

  def ends_on
    ends_at.try :to_date
  end

  def starts_on
    starts_at.to_date
  end

  def during_several_days?
    ends_on ? starts_on != ends_on : false
  end

  def self.tags
    search_params = { :starts_on_greater_than => Date.today, :starts_on_less_than => Date.today + 4.weeks }
    HasSearcher.searcher(:showings, search_params).faceted.facet(:tags).rows.map(&:value)
  end

  def self.nearest
    HasSearcher.searcher(:showings).actual.today.order(:starts_at).limit(5)
  end

  def get_longitude
    longitude? ? longitude : organization_address.try(:longitude)
  end

  def get_latitude
    latitude? ? latitude : organization_address.try(:latitude)
  end

end

# == Schema Information
#
# Table name: showings
#
#  id              :integer          not null, primary key
#  afisha_id       :integer
#  place           :string(255)
#  starts_at       :datetime
#  price_min       :integer
#  hall            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ends_at         :datetime
#  price_max       :integer
#  organization_id :integer
#  latitude        :string(255)
#  longitude       :string(255)
#

