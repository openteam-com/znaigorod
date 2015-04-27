class Manage::PhotogalleriesController < Manage::ApplicationController
  load_and_authorize_resource

  actions :all

  def index
    @collection = Photogallery.page(params[:page] || 1).per(20).order('id desc')
  end
end
