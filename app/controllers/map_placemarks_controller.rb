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
      success.html { render :nothing => true and return }
      failure.html { raise 'error' }
    }
  end

  private
  def build_resource
    if action_name == 'create'
      @map_placemark = MapPlacemark.new(params[:map_placemark].merge(:user_id => current_user.id))
    end
  end
end
