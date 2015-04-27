class AddPlaceholderToContests < ActiveRecord::Migration
  def change
    add_column :contests, :placeholder, :text
  end
end
