class My::GalleryImagesController < My::ApplicationController
  load_and_authorize_resource

  actions :index, :new, :create, :destroy

  belongs_to :account, :optional => true
  belongs_to :afisha,  :optional => true
  belongs_to :organizations,  :optional => true
  belongs_to :review,  :optional => true
  belongs_to :advert,  :optional => true

  custom_actions :collection => :destroy_all

  respond_to :html, :js, :json

  def index
    index! {
      @images = Kaminari.paginate_array(current_user.account.gallery_images).page(params[:page]).per(15)
      render :partial => 'account_gallery_images' and return if request.xhr?
    }
  end

  def destroy
    destroy! { render :nothing => true and return }
  end

  def destroy_all
    destroy_all! do
      parent.gallery_images.destroy_all

      redirect_to parent_path and return
    end
  end

  protected

  # защита от подмены accound_id на форме
  def association_chain
    super

    @association_chain = [current_user.account] if params[:account_id]

    @association_chain
  end

  def build_resource_params
    [:file => params.try(:[], :gallery_images).try(:[], :file)]
  end
end
