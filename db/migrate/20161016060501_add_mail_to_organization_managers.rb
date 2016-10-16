class AddMailToOrganizationManagers < ActiveRecord::Migration
  def change
    add_column :organization_managers, :email, :string
    add_column :organization_managers, :status, :string
  end
end
