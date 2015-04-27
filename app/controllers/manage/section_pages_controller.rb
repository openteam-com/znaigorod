class Manage::SectionPagesController < Manage::ApplicationController
  load_and_authorize_resource

  def create
    create! {
      redirect_to manage_organization_section_path(params[:organization_id], params[:section_id]) and return
    }
  end

  def update
    update! {
      redirect_to manage_organization_section_path(params[:organization_id], params[:section_id]) and return
    }
  end

  def destroy
    destroy! {
      redirect_to manage_organization_section_path(params[:organization_id], params[:section_id]) and return
    }
  end

  def destroy_poster
    section_page = SectionPage.find(params[:id])
    section_page.poster_image.destroy
    section_page.poster_image_url = nil
    section_page.save
    redirect_to edit_manage_organization_section_section_page_path(params[:organization_id], params[:section_id], params[:id]) and return
  end

  def sort
    begin
      params[:position].each do |id, position|
        SectionPage.find(id).update_attribute :position, position
      end
    rescue Exception => e
      render :text => e.message, :status => 500 and return
    end

    render :nothing => true, :status => 200
  end

  def build_resource
    Section.find(params[:section_id]).section_pages.new(params[:section_page])
  end

end
