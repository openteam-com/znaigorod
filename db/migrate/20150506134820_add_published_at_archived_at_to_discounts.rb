class AddPublishedAtArchivedAtToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :published_at, :datetime
    add_column :discounts, :archived_at, :datetime

    Discount.reset_column_information

    Discount.find_each do |discount|
      discount.update_attribute :published_at, discount.created_at
    end
  end
end
