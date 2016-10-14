class CreateOrganizationManagers < ActiveRecord::Migration
  def change
    create_table :organization_managers do |t|
      t.belongs_to :user
      t.belongs_to :organization

      t.timestamps
    end
  end
end
