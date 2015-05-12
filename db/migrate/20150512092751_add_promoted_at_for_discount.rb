class AddPromotedAtForDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :promoted_at, :timestamp
  end
end
