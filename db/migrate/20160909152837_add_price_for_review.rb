class AddPriceForReview < ActiveRecord::Migration
  def change
    add_column :reviews, :price, :integer
  end
end
