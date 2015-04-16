class AddColumnNavigationTitleToSections < ActiveRecord::Migration
  def change
    add_column :sections, :navigation_title, :string
  end
end
