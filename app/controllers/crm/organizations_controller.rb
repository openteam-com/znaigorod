class Crm::OrganizationsController < Crm::ApplicationController
  load_and_authorize_resource

  actions :index, :show, :edit, :update

  has_scope :page, default: 1

  def index
    @organizations = Organization.search{
      paginate :page => params[:page], :per_page => 10
      with :organization_category_slugs, search_field('suborganizations') if search_field('suborganizations').present?
      with :manager_id, search_field('manager_id') if search_field('manager_id').present?
      with :barter_status, search_field('barter_status') if search_field('barter_status').present?
      with :status, search_field('status') if search_field('status').present?
      keywords search_field('q') if search_field('q').present?
    }.results
  end

  def update
    update! { render partial: params[:field] and return }
  end

  def search_params
    @search_params ||= params[:search] || {}
  end

  def search_field(field)
    search_params[field]
  end
end
