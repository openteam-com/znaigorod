class Manage::OrganizationsController < Manage::ApplicationController
  load_and_authorize_resource

  belongs_to :organization, :optional => true

  has_scope :ordered_by_updated_at, :default => true, :type => :boolean
  has_scope :page, :default => 1
  has_scope :parental, :default => true, :type => :boolean, :only => :index

  before_filter :check_role
  before_filter :build_resource, :only => :new
  before_filter :build_nested_objects, :only => [:new, :edit]

  respond_to :html, :json

  def show
    if request.xhr?
      record = Organization.find(params[:id]).sections.create(title: params[:section_title])

      render :partial => 'section', :locals => { :resource => Organization.find(params[:id]), :section => record }, :status => 200 and return

    end
  end

  def update
    @organization = Organization.find(params[:id])
    @organization.attributes = params[:organization]
    if params[:commit] == 'Обрезать логотип'
      @organization.cropping_logotype_url
    end
    @organization.save
    redirect_to manage_organization_path(@organization.id)
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

  def build_nested_objects
    resource.organization_stand || resource.build_organization_stand
    resource.address || resource.build_address

    (1..7).each do |day|
      resource.schedules.build(:day => day)
    end unless resource.schedules.any?
  end

  def collection
    searcher = HasSearcher.searcher(:manage_organization, params).paginate(:page => params[:page], :per_page => per_page)
    searcher.order_by(:total_rating, :desc) if params[:rated]
    searcher.results
  end

  def check_role
    roles = current_user.roles
    unless roles.include? "organization_editor"
      redirect_to manage_affiches_path if roles.include? "affiche_editor"
      redirect_to manage_posts_path if roles.include? "post_editor"
    end
  end
end
