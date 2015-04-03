class AddCsvIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :csv_id, :integer
  end
end
