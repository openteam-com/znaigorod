class AddMainPageFlagToOrganizationCategory < ActiveRecord::Migration
  def change
    add_column :organization_categories, :show_on_main_page, :boolean
  end
end
