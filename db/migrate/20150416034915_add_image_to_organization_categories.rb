class AddImageToOrganizationCategories < ActiveRecord::Migration
  def change
    add_attachment :organization_categories, :default_image
    add_attachment :organization_categories, :hover_image
  end
end
