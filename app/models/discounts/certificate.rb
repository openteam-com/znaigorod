# encoding: utf-8

class Certificate < Discount
  include Copies
  include PaymentSystems

  attr_accessible :origin_price, :price, :number

  validates_presence_of :origin_price, :price, :number

  before_validation :set_discount

  def copies_for_sale?
    copies.for_sale.any?
  end

  private

  def set_discount
    self.discount = origin_price? ? ((1 - price.to_f / origin_price.to_f) * 100).round : 0
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

