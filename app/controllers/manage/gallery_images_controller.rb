class Manage::GalleryImagesController < Manage::ApplicationController
  load_and_authorize_resource

  actions :new, :create, :destroy, :update, :edit
  custom_actions :resource => :destroy_file

  belongs_to *Organization.available_suborganization_kinds,
    :polymorphic => true, :optional => true

  belongs_to :section, :afisha, :organization, :sauna_hall, :review, :room, :polymorphic => true, :optional => true

  def create
    @gallery_image = parent.gallery_images.create(:file => params[:gallery_images][:file])
  end

  def update
    update! { collection_path }
  end

  def destroy
    destroy! {
      render :nothing => true and return
    }
  end

  def destroy_file
    @gallery_image.file.destroy
    redirect_to [:edit, :manage, parent, @gallery_image]
  end

  protected
    def collection_path
      case parent
      when Afisha
        manage_afisha_show_path(parent)
      when Organization
        manage_organization_path(parent)
      when SaunaHall
        manage_organization_sauna_sauna_hall_path(@organization, parent)
      when *Organization.available_suborganization_classes
        manage_organization_path(parent.organization)
      when Post
        manage_post_path(parent)
      end
    end
end
