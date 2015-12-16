class AddAsCollageToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :as_collage, :boolean, :default => false
  end
end
