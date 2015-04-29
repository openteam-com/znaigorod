class RobokassaController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  skip_before_filter :verify_authenticity_token

  def paid
    notification = Robokassa::Notification.new(request.raw_post, secret: Settings['robokassa.secret_2'])

    if notification.acknowledge
      payment = Payment.find(notification.item_id)
      payment.approve!

      render text: notification.success_response
    else
      head :bad_request
    end
  end

  def success
    notification = Robokassa::Notification.new(request.raw_post, secret: Settings['robokassa.secret_1'])
    payment = Payment.find(notification.item_id)

    case payment.paymentable
    when Ticket
      redirect_to afisha_index_path(:has_tickets => true)
    when Bet
      redirect_to my_root_path
    when nil
      redirect_to cooperation_path
    else
      redirect_to root_path
    end
  end

  def fail
    notification = Robokassa::Notification.new(request.raw_post)
    payment = Payment.find(notification.item_id)
    paymentable = payment.paymentable
    begin
      payment.cancel_and_release_tickets!
    rescue
    end

    if paymentable
      if paymentable.is_a?(Ticket)
        redirect_to afisha_index_path(:has_tickets => true)
      end

      return
    end

    redirect_to cooperation_path
  end
end
