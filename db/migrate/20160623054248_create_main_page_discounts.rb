class CreateMainPageDiscounts < ActiveRecord::Migration
  def create_main_page_discount_records
    (1..6).each do |i|
      main_page_discount = MainPageDiscount.new(:position => i)
      main_page_discount.save :validate => false
    end
  end

  def change
    create_table :main_page_discounts do |t|
      t.integer :discount_id
      t.integer :position
      t.datetime :expires_at
      t.timestamps
    end

    create_main_page_discount_records
  end

end
