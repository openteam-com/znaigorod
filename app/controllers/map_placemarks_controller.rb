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

  def create
    create! { |success, failure|
      @map_project = MapProject.find(params[:map_project_id])
      success.html { @map_placemark = MapPlacemark.new; render :partial => 'content', :locals => { :@map_placemark => @map_placemark, :@map_project => @map_project } and return }
      failure.html { render :partial => 'content', :locals => { :@map_placemark => @map_placemark, :@map_project => @map_project } and return }
    }
  end

  private
  def build_resource
    if action_name == 'create'
      @map_placemark = MapPlacemark.new(params[:map_placemark].merge(:user_id => current_user.id))
    end
  end
end
