class Manage::OrganizationCategoriesController < Manage::ApplicationController
  authorize_resource

  def create
    @organization_category = params[:organization_category][:root] ?
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
    @organization_category.parent = OrganizationCategory.find(params[:organization_category][:parent])

    if @organization_category.save
      redirect_to  manage_organization_category_path(@organization_category)
    else
      render :action => :edit
    end
  end

  def destroy
    destroy! {
      redirect_to manage_organization_categories_path and return
    }
  end
end
