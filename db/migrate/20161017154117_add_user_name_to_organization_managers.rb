class AddUserNameToOrganizationManagers < ActiveRecord::Migration
  def change
    add_column :organization_managers, :user_name, :string
  end
end
