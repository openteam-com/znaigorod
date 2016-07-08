class My::GalleryFilesController < My::ApplicationController
  load_and_authorize_resource
  actions :new, :create, :destroy, :update, :edit
  custom_actions :collection => :destroy_all

  belongs_to *Organization.available_suborganization_kinds,
    :polymorphic => true, :optional => true

  belongs_to :afisha, :organization, :polymorphic => true, :optional => true

  def create
    @gallery_file = parent.gallery_files.create(:file => params[:gallery_files][:file])
  end

  def destroy
    destroy! {
      render :nothing => true and return
    }
  end

  def destroy_all
    destroy_all! {
      parent.gallery_files.destroy_all
      redirect_to edit_step_my_afisha_path(parent.id, :step => :sixth) and return if parent.class.name == 'Afisha'
      redirect_to edit_my_organization_path(parent.id) and return
    }
  end
end
