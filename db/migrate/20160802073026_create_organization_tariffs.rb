class CreateOrganizationTariffs < ActiveRecord::Migration
  def change
    create_table :organization_tariffs  do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :tariff, index: true
      t.string :duration
      t.integer :price
      t.timestamps
    end
  end
end
