class AddRequestToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :request_to_published, :boolean, :default => false
  end
end
