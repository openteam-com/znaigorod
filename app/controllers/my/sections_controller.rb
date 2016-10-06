class My::SectionsController < My::ApplicationController
  load_and_authorize_resource
  def new
    new!{
      @section.organization_id = params[:organization_id]
      @section.save
      redirect_to my_organization_section_path(params[:organization_id], @section) and return
    }
  end
end
