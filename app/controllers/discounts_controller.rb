class DiscountsController < ApplicationController
  inherit_resources

  actions :show

  def index

    respond_to do |format|
      format.html {
        @discounts = DiscountListPoster.where('discount_id is not null').actual.ordered.map{|discount| DiscountDecorator.new Discount.find(discount.discount_id)}
        @presenter = DiscountsPresenter.new(params)
        @discounts += @presenter.decorated_collection

        render partial: 'discounts/discount_posters', layout: false and return if request.xhr?

        @organizations = NewOrganizationsPresenter.new({:promoted_clients_per_page => 5})
      }

      format.rss {
        @presenter = DiscountsPresenter.new(:per_page => 15)
        render :layout => false
      }

      format.promotion {
        presenter = DiscountsPresenter.new(params.merge(:per_page => 5))

        render :partial => 'promotions/discounts', :locals => { :presenter => presenter }
      }
    end
  end

  def show
    show! do |format|
      format.html do
        @discount = DiscountDecorator.new(@discount)
        @kind_discounts = @discount.kind_discounts(@discount.kind.first)
        @type_discounts = @discount.type_discounts(@discount.type.try(:underscore))
        @presenter = DiscountsPresenter.new(params.merge(:kind => @discount.kind.map(&:value).first, :type => @discount.model.type_for_solr))
        @discount.delay(:queue => 'critical').create_page_visit(request.session_options[:id], request.user_agent, current_user)
        @members = @discount.members.page(1).per(3)
      end

      format.promotion do
        discount = DiscountDecorator.new(@discount)

        render :partial => 'promotions/discount', :locals => { :decorated_discount => discount }
      end
    end
  end
end
