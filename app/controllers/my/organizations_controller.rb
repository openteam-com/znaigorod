# encoding: utf-8

class My::OrganizationsController < My::ApplicationController
  load_and_authorize_resource
  defaults :resource_class => Organization

  before_filter :build_nested_objects, :only => [:new, :edit, :create]

  actions :all

  def index
    index! {
      @account = AccountDecorator.new(current_user.account)

      @organizations = @account.organizations.where("state != ?", 'close').page(1).per(16)
      @managed_organizations = current_user.managed_organizations.where("state != ?", 'close').page(1).per(16)
    }
  end

  def show
    @organization = OrganizationDecorator.new(Organization.find(params[:id]))
    redirect_to '/404' if @organization.close?
  end

  def create
    create! do |success, failure|
      success.html { redirect_to my_organization_path(resource) }
      failure.html { render :new }
    end
  end

  def update
    @organization = Organization.find(params[:id])
    @organization.attributes = params[:organization]

    if @organization.save
      if params[:edit_gallery_images]
        redirect_to edit_gallery_images_my_organization_path(@organization.id)
      elsif params[:edit_gallery_files]
        redirect_to edit_gallery_files_my_organization_path(@organization.id)
      else
        redirect_to my_organization_path(@organization.id)
      end
    else
      render :edit
    end
  end

  def destroy
    destroy! {
      organization_response = {}
      organization_response[:all] = current_user.organizations.count
      organization_response[:published] = current_user.organizations.by_state('published').count
      organization_response[:draft] = current_user.organizations.by_state('draft').count
      render :json => organization_response  and return if request.xhr?

      my_root_path
    }
  end

  def subscriptions
    @minimal = Tariff.minimal.first
    @middle = Tariff.middle.first
    @premium = Tariff.premium.first
  end

  def send_about_confirm_role
    @om = OrganizationManager.new(:organization_id => params[:id], :email => params[:user_email], :status => 'waiting')
    @om.user_name = User.find(params[:user_id]).name
    if @om.save
      @om.user_id_temp = params[:user_id]
      MyMailer.send_confirm_role(@om).deliver
    end
    redirect_to :back
  end

  def close_role
    @om = OrganizationManager.find(params[:organization_manager_id])
    MyMailer.close_role(@om).deliver
    @om.destroy
    redirect_to :back
  end

  def managing
  end

  def transfer_main_role
    @organization = Organization.find(params[:id])
    @user = User.where(:id => params[:user_id]).first
    if @organization && @user
      OrganizationManager.where("organization_id = ? and user_id = ?", @organization.id,  @user.id).map(&:destroy)
      OrganizationManager.create(:user_name => current_user.name, :email => current_user.email, :organization_id => @organization.id, :user_id => current_user.id, :status => 'true')
      @organization.update_attribute(:user_id, @user.id)
      redirect_to my_organizations_path
    else
      redirect_to managing_my_organization_path(params[:id])
    end
  end

  def available_tags
    @tags = Organization.available_tags(params[:term])

    respond_to do |format|
      format.json { render text: @tags }
      format.html { render :select_tags }
    end
  end

  def preview_video
    code = params[:organization].try(:[], :trailer_code)
    code.gsub!(/width=("|')(\d+)("|')/i, 'width="580"')
    code.gsub!(/height=("|')(\d+)("|')/i, 'height="350"')
    render text: Organization.trailer_auto_html(code)
  end

  def destroy_image
    @organization = Organization.find(params[:id])
    @organization.poster_url = nil
    @organization.poster_image.destroy
    @organization.poster_image_url = nil
    @organization.save(:validate => false)
    redirect_to edit_step_my_organization_path(@organization.id, :step => :second)
  end

  def send_to_published
    @organization = Organization.find(params[:id])
    @organization.update_attribute(:state, :moderation_to_published)
    MyMailer.send_to_published_organization(@organization).deliver
    redirect_to my_organizations_path
  end

  def close
    @organization = current_user.organizations.find(params[:id])
    @organization.update_attribute(:state, 'close')
    redirect_to my_organizations_path
  end

  def statistics
  end

  def social_gallery
    @organization = Organization.find(params[:id])

    @organization.download_album(params[:organization][:social_gallery_url])

    redirect_to edit_step_my_organization_path(@afisha.id, :step => :fourth)
  end

  def sort
    begin
      params[:position].each do |id, position|
        GalleryImage.find(id).update_attribute :position, position
      end
    rescue Exception => e
      render :text => e.message, :status => 500 and return
    end

    render :nothing => true, :status => 200
  end

  private

  alias_method :old_build_resource, :build_resource

  def build_nested_objects
    resource.organization_stand || resource.build_organization_stand
    resource.address || resource.build_address
    resource.brand_for_content || resource.build_brand_for_content
    resource.full_schedules.present? || resource.full_schedules.build
  end

  def build_resource
    old_build_resource.tap do |object|
      object.user = current_user
    end
  end
end
