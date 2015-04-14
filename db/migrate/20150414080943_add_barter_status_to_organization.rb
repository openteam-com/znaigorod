class AddBarterStatusToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :barter_status, :string, :default => :no_information
  end
end
