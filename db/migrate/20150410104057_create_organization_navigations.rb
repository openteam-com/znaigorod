class CreateOrganizationNavigations < ActiveRecord::Migration
  def change
    create_table :organization_navigations do |t|
      t.string :title
      t.string :href
      t.integer :position
      t.string :organization_id
      t.timestamps
    end
  end
end
