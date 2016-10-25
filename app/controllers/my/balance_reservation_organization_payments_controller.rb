class My::BalanceReservationOrganizationPaymentsController < My::ApplicationController
  skip_authorization_check

  def create
    @organization = Organization.find(params['organization_id'])
    @reservation = @organization.reservation
    @balance_payment = @organization
      .balance_reservation_organization_payments
      .new(:amount => params[:amount])
    @balance_payment.user = current_user

    if @balance_payment.save
      redirect_to @balance_payment.service_url
    else
      render :new
    end
  end
end
