class ReviewPayment < Payment
  attr_accessible :amount

  def approve!
    super

    paymentable.to_published!
    create_notification_message
  end

  private

  def payment_system
    :robokassa
  end

  alias :review :paymentable

  def create_notification_message
    if user
      NotificationMessage.delay(:queue => 'critical').create(:account => user.account, :kind => :set_tariff, :messageable => organization)
    end
  end
end
