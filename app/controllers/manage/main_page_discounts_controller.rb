class Manage::MainPageDiscountsController < Manage::ApplicationController
  load_and_authorize_resource

  actions :all, :except => [:new, :create, :show, :destroy]

  def index
    @main_page_discounts = MainPageDiscount.ordered

    search = Discount.search { fulltext params[:term]; with :state, :published }
    discounts = search.results

    respond_to do |format|
      format.html
      format.json { render :json => discounts.map { |r|  { :label => r.title, :value => r.id } } }
    end
  end

end
