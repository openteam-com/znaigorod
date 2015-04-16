class AddColumnsNavigationTitleToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :discounts_navigation_title, :string
    add_column :organizations, :photos_navigation_title, :string
    add_column :organizations, :afishas_navigation_title, :string
    add_column :organizations, :reviews_navigation_title, :string
    add_column :organizations, :address_navigation_title, :string
  end
end
