# encoding: utf-8

class My::OrganizationsController < My::ApplicationController
  load_and_authorize_resource
  defaults :resource_class => Organization

  before_filter :build_nested_objects, :only => [:new, :edit]

  actions :all

  def index
    index! {
      @account = AccountDecorator.new(current_user.account)

      @organizations = @account.organizations.where("state != ?", 'close').page(1).per(16)
    }
  end

  def show
    @organization = OrganizationDecorator.new(current_user.organizations.find(params[:id]))
    redirect_to '/404' if @organization.close?
  end

  def create
    create! do |success, failure|
      success.html { redirect_to my_organization_path(resource) }
    end
  end

  def edit
    @organization = current_user.organizations.find(params[:id])
  end

  def update
    @organization = current_user.organizations.find(params[:id])
    @organization.attributes = params[:organization]

    if @organization.save
      if params[:crop]
        redirect_to edit_my_organization_path(@organization.id)
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
    @organization = current_user.organizations.find(params[:id])
    @organization.poster_url = nil
    @organization.poster_image.destroy
    @organization.poster_image_url = nil
    @organization.save(:validate => false)
    redirect_to edit_step_my_organization_path(@organization.id, :step => :second)
  end

  def send_to_published
    @organization = current_user.organizations.find(params[:id])
    @organization.update_attribute(:state, :moderation_to_published)
    MyMailer.send_to_published_organization(@organization).deliver
    redirect_to my_organizations_path
  end

  def close
    @organization = current_user.organizations.find(params[:id])
    @organization.update_attribute(:state, 'close')
    redirect_to my_organizations_path
  end

  def social_gallery
    @organization = current_user.organizations.find(params[:id])

    @organization.download_album(params[:organization][:social_gallery_url])

    redirect_to edit_step_my_organization_path(@afisha.id, :step => :fourth)
  end

  private

  alias_method :old_build_resource, :build_resource

  def build_nested_objects
    resource.organization_stand || resource.build_organization_stand
    resource.address || resource.build_address

    (1..7).each do |day|
      resource.schedules.build(:day => day)
    end unless resource.schedules.any?
  end

  def build_resource
    old_build_resource.tap do |object|
      object.user = current_user
    end
  end
end
