# encoding: utf-8

class My::DiscountsController < My::ApplicationController
  load_and_authorize_resource

  actions :all

  custom_actions :resource => [:poster, :send_to_published, :send_to_draft]

  def index
    index!{
      @account = AccountDecorator.new(current_user.account)
      if params[:page].nil?
        @discounts = @account.discounts.page(1).per(12)
      else
        if params[:by_state].present?
          @discounts = @account.discounts.by_state(params[:by_state]).page(params[:page]).per(12)
          render partial: "my/discounts/discount_posters", :locals => { collection: @discounts, state: params[:by_state].to_sym }, layout: false and return if request.xhr?
        else
          @discounts = current_user.account.discounts.page(params[:page]).per(12)
          render partial: "my/discounts/discount_posters", :locals => { collection: @discounts, state: :all }, layout: false and return if request.xhr?
        end
      end
    }
  end

  def show
    @discount = DiscountDecorator.new(@discount)
  end

  def update
    update! do |success, failure|
      success.html {
        if params[:crop]
          redirect_to poster_my_discount_path(resource)
        else
          redirect_to my_discount_path(resource)
        end
      }

      failure.html {
        render :poster and return if params[:crop]

        render :edit
      }
    end
  end

  def send_to_published
    @discount = current_user.account.discounts.find(params[:id])
    @discount.published_at = Time.zone.now
    @discount.to_published!

    redirect_to discount_path(@discount), :notice => "Информация о скидке «#{@discount.title}» опубликована."
  end

  def send_to_draft
    @discount = current_user.account.discounts.find(params[:id])
    @discount.to_draft!

    redirect_to my_discount_path(@discount), :notice => "Информация о скидке «#{@discount.title}» возвращена в черновики."
  end

  def destroy
    destroy! {
      discounts_response = {}
      discounts_response[:all] = current_user.account.discounts.count
      discounts_response[:published] = current_user.account.discounts.by_state('published').count
      discounts_response[:draft] = current_user.account.discounts.by_state('draft').count

      render :json => discounts_response  and return if request.xhr?

      my_root_path
    }
  end

  private
    alias_method :old_build_resource, :build_resource

    def build_resource
      old_build_resource.tap do |object|
        object.account = current_user.account
      end
    end
end
