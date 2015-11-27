class MapPlacemarksController < ApplicationController
  inherit_resources

  actions :all

  layout 'map_projects'

  def index
    index! {
      @map_project = MapProject.find(params[:id])
      @map_placemark = MapPlacemark.new
    }
  end

  def new

  end

end
