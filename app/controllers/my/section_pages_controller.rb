class My::SectionPagesController < My::ApplicationController
  load_and_authorize_resource

  def create
    create! do |success, failure|
      success.html { redirect_to my_organization_section_path(params[:organization_id], params[:section_id]) and return }
      failure.html { render :new and return }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to my_organization_section_path(params[:organization_id], params[:section_id]) and return }
      failure.html { render :edit and return }
    end
  end

  def destroy
    destroy! {
      redirect_to my_organization_section_path(params[:organization_id], params[:section_id]) and return
    }
  end

  def destroy_poster
    section_page = SectionPage.find(params[:id])
    section_page.poster_image.destroy
    section_page.poster_image_url = nil
    section_page.save
    redirect_to edit_my_organization_section_section_page_path(params[:organization_id], params[:section_id], params[:id]) and return
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
