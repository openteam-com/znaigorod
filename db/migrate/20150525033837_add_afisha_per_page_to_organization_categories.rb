class AddAfishaPerPageToOrganizationCategories < ActiveRecord::Migration
  def change
    add_column :organization_categories, :afisha_per_page, :integer, :default => 1000
    OrganizationCategory.update_all(:afisha_per_page => 1000)
  end
end
