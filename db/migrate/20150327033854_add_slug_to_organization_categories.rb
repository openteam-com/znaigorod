class AddSlugToOrganizationCategories < ActiveRecord::Migration
  def change
    add_column :organization_categories, :slug, :string

    OrganizationCategory.find_each do |oc|
      oc.save
    end
  end
end
