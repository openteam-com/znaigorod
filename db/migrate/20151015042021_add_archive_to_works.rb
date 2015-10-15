class AddArchiveToWorks < ActiveRecord::Migration
  def change
    add_column :works, :archive, :boolean, :default => false
    Contest.find("miss-pivovarochka-2015-v-tomske").works.update_all(:archive => true)
  end
end
