class AddAssociatedChangesToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :associated_changes, :string
  end
end
