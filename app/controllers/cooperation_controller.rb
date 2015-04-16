class CooperationController < ApplicationController
  helper_method :view_type

  def benefit
  end

  def statistics
  end

  def extra_catalogs
  end

  def services
    @service_payment = ServicePayment.new
  end

  def our_customers
    @presenter = NewOrganizationsPresenter.new(params.merge(:view_type => 'tile'))

    render partial: 'organizations/tile_view_posters', layout: false and return if request.xhr?
  end

  def view_type
    'tile'
  end

  def ticket_sales
  end
end
