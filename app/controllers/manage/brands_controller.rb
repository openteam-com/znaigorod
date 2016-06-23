class Manage::BrandsController < Manage::ApplicationController
  load_and_authorize_resource
  before_filter :find_brand, only: [:show, :edit, :update]
  def index
    @brands = Brand.all
  end

  def edit
  end

  def update
    if @brand.update_attributes(params['brand'])
      redirect_to manage_brands_path
    else
      render :edit
    end
  end

  def find_brand
    @brand = Brand.find(params['id'])
  end
end
