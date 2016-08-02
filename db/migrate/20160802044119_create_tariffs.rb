class CreateTariffs < ActiveRecord::Migration
  def change
    create_table :tariffs do |t|
      t.string :title
      t.string :description
      t.integer :price_for_month
      t.integer :price_for_six_months
      t.integer :price_for_year
      t.belongs_to :organization

      t.timestamps
    end
  end
end
