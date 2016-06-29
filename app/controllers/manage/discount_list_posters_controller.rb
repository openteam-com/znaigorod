class Manage::DiscountListPostersController < Manage::ApplicationController
  authorize_resource

  def index
    @discount_list_posters = DiscountListPoster.ordered

    search = Discount.search { fulltext params[:term]; with :state, :published }
    discounts = search.results

    respond_to do |format|
      format.html
      format.json { render :json => discounts.map { |r|  { :label => r.title, :value => r.id } } }
    end
  end

  def edit
    @discount_list_poster = DiscountListPoster.find(params[:id])
  end

  def update
    @discount_list_poster = DiscountListPoster.find(params[:id])
    @discount_list_poster.update_attributes(params[:discount_list_poster])
    Discount.find(params[:discount_list_poster][:discount_id]).update_attributes(promoted_at: params[:discount_list_poster][:expires_at]) if params[:discount_list_poster][:expires_at]
    redirect_to manage_discount_list_posters_path
  end


end

