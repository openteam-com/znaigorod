class BalanceReservationOrganizationPayment < Payment
  attr_accessible :amount
  def approve!
    super

    set_balance_reservation
    create_notification_message
  end

  private

  def payment_system
    :robokassa
  end

  alias :organization :paymentable

  def set_balance_reservation
    organization.reservation.update_attribute(:balance, amount + organization.reservation.balance)
  end

  def create_notification_message
    if user
      NotificationMessage.delay(:queue => 'critical').create(:account => user.account, :kind => :set_balance, :messageable => :reservation)
    end
  end
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

