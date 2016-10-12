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

  def requests_to_published
    @organizations = Organization.where(:state => :moderation_to_published)
  end

  def update
    if params['organization']['state'].present?
      if params['organization']['state'] == 'published' && !@organization.published?
        @organization.create_feed unless @organization.feed.present? || @organization.user.nil?
        ManageMailer.message_about_publication(@organization).deliver if @organization.email.present?
      end
    end

    if params['organization']['clone_id'].present?
      original = Organization.find(params['organization']['clone_id'])
      original.update_attribute(:user_id, @organization.user.id) if @organization.user.present?
      @organization.destroy
      original.create_feed unless original.feed.present? if original.user.present?
      redirect_to manage_organization_path(original) and return
    end


    @organization.update_attributes(params['organization'])
    redirect_to manage_organization_path(@organization) and return

  end

  def closed
    @organizations = Organization.where(:state => :close)
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
