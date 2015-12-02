class Manage::MapPlacemarksController < Manage::ApplicationController
  load_and_authorize_resource

  def new
    new!{
      @map_project = MapProject.find(params[:map_project_id])
    }
  end

  def edit
    edit!{
      @map_project = MapProject.find(params[:map_project_id])
    }
  end

  def create
    create! do |success, failure|
      @map_project = MapProject.find(params[:map_project_id])
      success.html { @map_placemark.to_published!; redirect_to manage_map_project_path(@map_project)}
      failure.html { render :new }
    end
  end

  def update
    update! do |success, failure|
      @map_project = MapProject.find(params[:map_project_id])
      success.html { redirect_to manage_map_project_path(@map_project)}
      failure.html { render :edit }
    end
  end

  def destroy
    destroy!{
      redirect_to manage_map_project_path(params[:map_project_id]) and return
    }
  end

  def toggle_states
    @map_placemark = MapPlacemark.find(params[:map_placemark_id])
    @map_placemark.draft? ? @map_placemark.to_published! : @map_placemark.to_draft!
    redirect_to manage_map_project_path(params[:map_project_id]) and return
  end
end
