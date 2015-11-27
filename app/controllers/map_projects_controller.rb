class MapProjectsController < ApplicationController
  inherit_resources

  actions :all

  layout 'map_projects'

  def show
    show! {
      if params[:layer]
        @map_layer = MapLayer.find(params[:layer])
        @map_placemarks = @map_layer.map_placemarks.actual
      else
        @map_placemarks = MapProject.find(params[:id]).map_layers.flat_map { |layer| layer.map_placemarks.actual }.uniq
      end
      @reviews = ReviewDecorator.decorate(MapProject.find(params[:id]).relations.map(&:slave).sort_by(&:created_at).reverse)
    }
  end
end
