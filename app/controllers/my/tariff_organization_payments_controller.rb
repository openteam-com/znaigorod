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
    duration = params['duration'].to_i
    if duration >= 1 && duration < 6
      return tariff.price_for_month * duration
    elsif duration == 6
      return tariff.price_for_six_months
    elsif duration > 6 && duration < 12
      return tariff.price_for_six_months + (duration - 6) * tariff.price_for_month
    elsif duration == 12
      return tariff.price_for_year
    else
      return ''
    end
  end
end
