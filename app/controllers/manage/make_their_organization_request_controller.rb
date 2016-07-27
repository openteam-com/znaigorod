class Manage::MakeTheirOrganizationRequestController < Manage::ApplicationController
  load_and_authorize_resource
  def index
    @requests = MakeTheirOrganizationRequest.all
  end

  def show
    @request = MakeTheirOrganizationRequest.find(params['id'])
    @request = MakeTheirOrganizationRequest.find(params['id'])
  end

  def allow
    @request = MakeTheirOrganizationRequest.find(params['make_their_organization_request_id'])
    @request.user.organizations << @request.organization
    @request.destroy
    redirect_to manage_make_their_organization_request_index_path
  end

  def disallow
    @request = MakeTheirOrganizationRequest.find(params['make_their_organization_request_id'])
    @request.destroy
    redirect_to manage_make_their_organization_request_index_path
  end
end
