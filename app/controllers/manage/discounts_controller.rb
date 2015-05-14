class Manage::DiscountsController < Manage::ApplicationController
  load_and_authorize_resource

  actions :all
  custom_actions :resource => :fire_state_event

  has_scope :page, :default => 1
  has_scope :by_state, :only => :index
  has_scope :by_kind, :only => :index

  def edit
    edit! {
      render text: params[:id] and return if request.xhr?
    }
  end

  def update
    update! do |success, failure|
      success.html {
        render :nothing => true and return if request.xhr?

        if params[:crop]
          redirect_to poster_manage_discount_path(resource)
        else
          redirect_to manage_discount_path(resource)
        end
      }

      failure.html {
        render :poster and return if params[:crop]

        render :edit
      }
    end
  end

  def fire_state_event
    fire_state_event! {
      resource.fire_state_event(params[:event]) if resource.state_events.include?(params[:event].to_sym)

      redirect_to manage_discount_path(resource.id), :notice => resource.errors.full_messages and return unless resource.errors.messages.empty?
      redirect_to manage_discount_path(resource) and return
    }
  end

  private

  def collection
    @collection = Discount.search {
      keywords params[:q]
      with :state, params[:by_state] if params[:by_state].present?
      with :kind, params[:by_kind].singularize if params[:by_kind].present?
      order_by :created_at, :desc
      paginate paginate_options.merge(:per_page => per_page)
    }.results
  end
end
