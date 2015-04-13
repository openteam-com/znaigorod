class Manage::OrganizationNavigationsController < Manage::ApplicationController
  load_and_authorize_resource

  def new
    @organization = Organization.find(params[:organization_id])
    @select_sollection = ['Фото', 'Афиша', 'Скидки', 'Обзоры'] + @organization.sections.pluck(:title)
  end

  def edit
    @organization = Organization.find(params[:organization_id])
    @select_sollection = ['Фото', 'Афиша', 'Скидки', 'Обзоры'] + @organization.sections.pluck(:title)
    @selected = @organization.organization_navigations.find(params[:id]).original_href
  end

  def create
    create! {
      redirect_to manage_organization_path(params[:organization_id]) and return
    }
  end

  def update
    update! {
      redirect_to manage_organization_path(params[:organization_id]) and return
    }
  end

  def sort
    begin
      params[:position].each do |id, position|
        OrganizationNavigation.find(id).update_attributes(:position => position, :skip_callbacks => true)
      end
    rescue Exception => e
      render :text => e.message, :status => 500 and return
    end

    render :nothing => true, :status => 200
  end
end
