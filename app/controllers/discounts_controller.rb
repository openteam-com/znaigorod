class DiscountsController < ApplicationController
  inherit_resources

  actions :show

  def index
    @presenter = DiscountsPresenter.new(params)
    @discounts = @presenter.collection

    render partial: 'discounts/discount_posters', layout: false and return if request.xhr?
  end

  def show
    show! {
      @discount = DiscountDecorator.new(@discount)
      @presenter = DiscountsPresenter.new(params.merge(:kind => @discount.kind.map(&:value).first, :type => @discount.model.class.name.underscore))
      @discount.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
      @members = @discount.members.page(1).per(3)
    }
  end
end
