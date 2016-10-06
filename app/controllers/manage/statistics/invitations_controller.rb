class Manage::Statistics::InvitationsController < Manage::ApplicationController
  load_and_authorize_resource

  def index
    if params[:search] && params[:search]['starts_at'].present?
      @starts_at = Time.zone.parse(params[:search]['starts_at']).beginning_of_day
    else
      @starts_at = Time.zone.today.beginning_of_month
    end

    if params[:search] && params[:search]['ends_at'].present?
      @ends_at = Time.zone.parse(params[:search]['ends_at']).end_of_day
    else
      @ends_at = Time.zone.today.end_of_day
    end

    @invitations = Invitation.with_invited.where('invitations.created_at >= ? and invitations.created_at <= ?', @starts_at, @ends_at)

    @service_payments = ServicePayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)

    @promote_afisha_payments = PromoteAfishaPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @published_review_payments = ReviewPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @promote_discount_payments = PromoteDiscountPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)

    @afishas = Afisha.published.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @afishas_person = @afishas.where('user_id not in (?)', Role.all.map(&:user_id))

    @tickets = Ticket.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @sold_tickets = CopyPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).where(:paymentable_type => 'Ticket')

    @reservcations = Reservation.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @sms_claims = SmsClaim.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)

    @offered_discounts = OfferedDiscount.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @offers = Offer.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)

    @discounts = Discount.where('created_at >= ? and created_at <= ? and type is null', @starts_at, @ends_at)
    @discounts_person = @discounts.where('account_id not in (?)', Role.all.map(&:user).flat_map(&:account_id))

    @certificaces = Certificate.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @certificates_payments = CopyPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).where(paymentable_type: 'Discount', paymentable_id: Certificate.all)

    @coupons = Coupon.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @coupons_payments = CopyPayment.approved.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).where(paymentable_type: 'Discount', paymentable_id: Coupon.all)

    @private_messages = PrivateMessage.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)

    @accounts = Account.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @visits = Visit.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @votes = Vote.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).liked
    @friends = Friend.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @comments = Comment.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at)
    @invitation_states = Invitation.without_invited.where('invitations.created_at >= ? and invitations.created_at <= ?', @starts_at, @ends_at)

    @organization_show_phones = PhoneLookup.where('created_at >= ? and created_at <= ?', @starts_at, @ends_at).count
  end
end

