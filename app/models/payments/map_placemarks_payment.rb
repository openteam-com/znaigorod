class MapPlacemarksPayment  < Payment
  def approve!
    super

    map_placemark.to_published! if map_placemark.draft?
  end

  default_value_for :amount, '300'

  private

  def payment_system
    :robokassa
  end

  alias :map_placemark :paymentable
end

# == Schema Information
#
# Table name: payments
#
#  id               :integer          not null, primary key
#  paymentable_id   :integer
#  number           :integer
#  phone            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  paymentable_type :string(255)
#  type             :string(255)
#  amount           :float
#  details          :text
#  state            :string(255)
#  email            :string(255)
#

