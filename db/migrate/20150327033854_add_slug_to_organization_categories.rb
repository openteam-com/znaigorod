class AddSlugToOrganizationCategories < ActiveRecord::Migration
  def change
    add_column :organization_categories, :slug, :string
  end
end
