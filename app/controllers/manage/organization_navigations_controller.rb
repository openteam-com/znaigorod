class Manage::OrganizationNavigationsController < Manage::ApplicationController
  load_and_authorize_resource

  def create
    create! {
      redirect_to manage_organization_path(params[:organization_id]) and return
    }
  end
end
