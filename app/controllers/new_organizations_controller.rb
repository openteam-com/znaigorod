class NewOrganizationsController < ApplicationController
  def index

    @category = OrganizationCategory.all.detect { |c| c.title.from_russian_to_param == params[:category] }
    @categories = OrganizationCategory.roots
    @placemarks = Organization.where(status: :client)

    category = @category

    search = Organization.search {
      with :organization_category, category.downcased_title if category
      #with :features, params[:features] if params[:features].try
    }

    @results = search.results
  end
end
