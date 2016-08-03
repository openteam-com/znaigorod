class My::TariffOrganizationPaymentsController < My::ApplicationController
  skip_authorization_check

  def create
    @organization = Organization.find(params['organization_id'])
    @tariff_organization_payment = @organization
      .tariff_organization_payments
      .new(:tariff_id => params['tariff_id'], :duration => params['duration'], :amount => get_price)
    @tariff_organization_payment.user = current_user

    if @tariff_organization_payment.save
      redirect_to @tariff_organization_payment.service_url
    else
      render :new
    end
  end

  def get_price
    tariff = Tariff.find(params['tariff_id'])
    case params['duration']
    when 'month'
      tariff.price_for_month
    when 'six_months'
      tariff.price_for_six_months
    when 'year'
      tariff.price_for_year
    end
  end
end
