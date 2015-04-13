class CreateOrganizationNavigations < ActiveRecord::Migration
  def change
    create_table :organization_navigations do |t|
      t.string :title
      t.string :original_href
      t.string :href
      t.integer :position
      t.belongs_to :organization
      t.timestamps
    end
  end
end
