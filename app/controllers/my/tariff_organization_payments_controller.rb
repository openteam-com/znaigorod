class My::TariffOrganizationPaymentsController < My::ApplicationController
  inherit_resources
  actions :new, :create

  belongs_to :organization

  defaults :singleton => true

  layout false

  skip_authorization_check

  def create
    create! { |success, failure|
      success.html { redirect_to @tariff_organization_payment.service_url and return }
      failure.html { render :new and return }
    }
  end

  protected

  def build_resource
    @organization = Organization.find(params['organization_id'])
    @tariff_organization_payment = @organization.tariff_organization_payments.new(params['tariff_id'], params['duration'])
    @tariff_organization_payment.user = current_user

    @tariff_organization_payment
  end
end
