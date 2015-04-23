class Manage::OrganizationCategoriesController < Manage::ApplicationController
  authorize_resource

  def create
    @organization_category = params[:root] ?
                              OrganizationCategory.new(params[:organization_category].except(:parent)) :
                              OrganizationCategory.find(params[:organization_category][:parent]).children.new(params[:organization_category].except(:parent))

    if @organization_category.save
      redirect_to  manage_organization_category_path(@organization_category)
    else
      render :action => :new
    end
  end

  def update
    @organization_category = OrganizationCategory.find(params[:id])
    @organization_category.update_attributes(params[:organization_category].except(:parent))

    params[:root] ?
      @organization_category.parent = nil :
      @organization_category.parent = OrganizationCategory.find(params[:organization_category][:parent])

    if @organization_category.save
      redirect_to  manage_organization_category_path(@organization_category)
    else
      render :action => :edit
    end
  end

  def sort
    begin
      params[:position].each do |id, position|
        org_category = OrganizationCategory.find(id)
        org_category.sort_flag = true
        org_category.update_attribute :position, position
      end
    rescue Exception => e
      render :text => e.message, :status => 500 and return
    end

    render :nothing => true, :status => 200
  end

  def destroy
    destroy! {
      redirect_to manage_organization_categories_path and return
    }
  end
end
