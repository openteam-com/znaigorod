class AddCustomBaloonIconToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :show_custom_balloon_icon, :boolean, :default => :false
  end
end
