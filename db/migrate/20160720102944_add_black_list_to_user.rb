class AddBlackListToUser < ActiveRecord::Migration
  def change
    add_column :users, :black_list, :boolean, :default => false
  end
end
