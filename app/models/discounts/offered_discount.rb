class OfferedDiscount < Discount
  attr_accessor :places_attributes

  attr_accessible :placeholder, :afisha_id, :places_attributes

  accepts_nested_attributes_for :places, :allow_destroy => true

  # disable validation
  def sale?
    true
  end

  delegate :clear, :to => :places, :prefix => true
  before_validation :places_clear, :if => :afisha_id?

  after_save :create_places, :if => :afisha_id?

  private

  def create_places_from_organizations_addresses
    afisha.organizations.each do |organization|
      places.create! :organization_id => organization.id, :address => organization.title,
        :latitude => organization.latitude, :longitude => organization.longitude
    end
  end

  def create_places_from_showings
    afisha.showings.pluck(:place).uniq.each do |place|
      geo_info = YampGeocoder.new.geo_info_for(place)
      places.create! :address => place, :longitude => geo_info.longitude, :latitude => geo_info.latitude
    end
  end

  def create_places
    places_clear

    afisha.organizations.any? ? create_places_from_organizations_addresses
      : create_places_from_showings
  end
end

# == Schema Information
#
# Table name: discounts
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  description               :text
#  poster_url                :text
#  type                      :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  poster_image_url          :text
#  starts_at                 :datetime
#  ends_at                   :datetime
#  slug                      :string(255)
#  total_rating              :float
#  kind                      :text
#  number                    :integer
#  origin_price              :integer
#  price                     :integer
#  discounted_price          :integer
#  discount                  :integer
#  payment_system            :string(255)
#  state                     :string(255)
#  account_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  constant                  :boolean
#  sale                      :boolean          default(FALSE)
#  poster_vk_id              :text
#  terms                     :text
#  supplier                  :text
#  placeholder               :text
#  afisha_id                 :integer
#  external_id               :string(255)
#  discount_type             :string(255)
#  email_addresses           :text
#  stale                     :boolean
#  published_at              :datetime
#  archived_at               :datetime
#  promoted_at               :datetime
#

