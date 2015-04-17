class CreateFeatureOrganizations < ActiveRecord::Migration
  def change
    create_table :feature_organizations do |t|
      t.references :feature
      t.references :organization

      t.timestamps
    end
    add_index :feature_organizations, :feature_id
    add_index :feature_organizations, :organization_id
  end
end
