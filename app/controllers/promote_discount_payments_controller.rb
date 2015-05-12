class PromoteDiscountPaymentsController < ApplicationController
  inherit_resources

  actions :create

  belongs_to :discount

  skip_authorization_check

  def create
    create! do |success, failure|
      success.html { redirect_to @promote_discount_payment.service_url and return }
    end
  end

  protected

  def resource_instance_name
    :promote_discount_payment
  end

  def build_resource
    super
    @promote_discount_payment.user = current_user

    @promote_discount_payment
  end
end
