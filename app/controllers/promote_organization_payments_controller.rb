class PromoteOrganizationPaymentsController < ApplicationController
  skip_authorization_check

  def create
    @organization = Organization.find(params['organization_id'])
    @promote_organization_payment = @organization
      .promote_organization_payments
      .new()
    @promote_organization_payment.user = current_user

    if @promote_organization_payment.save
      redirect_to @promote_organization_payment.service_url
    else
      render :new
    end
  end
end
