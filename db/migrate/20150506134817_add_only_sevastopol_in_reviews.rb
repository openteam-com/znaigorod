class AddOnlySevastopolInReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :only_sevastopol, :boolean
  end
end
