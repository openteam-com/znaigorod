class AffiliatedCoupon < Discount
  attr_accessible :external_id

  validates_presence_of :external_id

  serialize :supplier, Hashie::Mash
  serialize :terms,    Array

  def label_url
    URI(supplier.link).host
  end

  def type_for_solr
    'coupon'
  end

  def should_generate_new_friendly_id?
    true
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

