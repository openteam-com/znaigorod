class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :title
      t.references :organization_category
      t.timestamps
    end
  end
end
