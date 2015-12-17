class My::OrganizationsController < My::ApplicationController
  #inherit_resources

  load_and_authorize_resource
  #actions :all
  belongs_to :organization, :optional => true

  has_scope :ordered_by_updated_at, :default => true, :type => :boolean
  has_scope :page, :default => 1
  has_scope :parental, :default => true, :type => :boolean, :only => :index

  #before_filter :check_role
  before_filter :build_resource, :only => :new
  before_filter :build_nested_objects, :only => [:new, :edit]

  respond_to :html, :json

  def index
    #@organizations = current_user.organizations

    respond_to do |format|
      format.html{
        @presenter = OrganizationsPresenterBuilder.new(params.merge( { :current_user => current_user } )).build
      }
    end
  end

  def new
    new!{
    (1..7).each do |day|
      resource.schedules.build(:day => day)
    end unless resource.schedules.any?
    }
  end

  private

  def build_nested_objects
    resource.organization_stand || resource.build_organization_stand
    resource.address || resource.build_address

    (1..7).each do |day|
      resource.schedules.build(:day => day)
    end unless resource.schedules.any?
  end


  def build_resource
    @organization = current_user.organizations.new(params[:organization])
  end
end
