class RemoveOnlySevastopolFromReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :only_sevastopol
  end
end
