class AddPositionToOrganizationCategories < ActiveRecord::Migration
  def change
    add_column :organization_categories, :position, :integer, default: 1
  end
end
