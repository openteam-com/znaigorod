class Manage::PlacedBannersController < Manage::ApplicationController
  load_and_authorize_resource

  before_filter :find_placed_banner, only: [:show, :edit, :destroy, :update]

  def index
    @placed_banners = PlacedBanner.all
  end

  def show
  end

  def new
    @placed_banner = PlacedBanner.new
  end

  def edit
  end

  def create
    @placed_banner = PlacedBanner.new(placed_banner_params)
    if @placed_banner.save
      redirect_to manage_placed_banners_path
    else
      render :new
    end
  end

  def update
    if @placed_banner.update_attributes(placed_banner_params)
      redirect_to manage_placed_banners_path
    else
      render :edit
    end
  end

  def destroy
    @placed_banner.delete
    redirect_to manage_placed_banners_path
  end

  def placed_banner_params
    params["placed_banner"]
  end

  private
  def find_placed_banner
    @real_banner = PlacedBanner.find(params[:id])
  end
end
