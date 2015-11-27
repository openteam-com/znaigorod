class MapPlacemarksPaymentController < ApplicationController
  inherit_resources

  actions :create

  belongs_to :map_placemark

  skip_authorization_check

  def create
    create! do |success, failure|
      success.html { redirect_to @map_placemarks_payment.service_url and return }
      #success.html { raise '111' }
    end
  end

  protected

  def resource_instance_name
    :map_placemarks_payment
  end

  def build_resource
    super
    @map_placemarks_payment.user = current_user

    @map_placemarks_payment
  end
end
