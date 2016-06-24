class CreateDiscountListPosters < ActiveRecord::Migration
  def create_list_discount_records
    (1..4).each do |i|
      list_discount = DiscountListPoster.new(:position => i)
      list_discount.save :validate => false
    end
  end

  def change
    create_table :discount_list_posters do |t|
      t.integer :position
      t.datetime :expires_at
      t.belongs_to :discount
      t.timestamps
    end

    create_list_discount_records
  end
end
