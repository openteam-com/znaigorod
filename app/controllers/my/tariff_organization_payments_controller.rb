class My::TariffOrganizationPaymentsController < My::ApplicationController
  skip_authorization_check

  def create
    @organization = Organization.find(params['organization_id'])
    @tariff_organization_payment = @organization
      .tariff_organization_payments
      .new(:tariff_id => params['tariff_id'], :duration => params['duration'])
    @tariff_organization_payment.user = current_user

    if @tariff_organization_payment.save
      redirect_to @tariff_organization_payment.service_url
    else
      render :new
    end
  end
end
