class ChangeRealBanner < ActiveRecord::Migration
  def change
    add_column :real_banners, :time_to, :datetime
    remove_column :real_banners, :width
    remove_column :real_banners, :height
    remove_column :real_banners, :show
    rename_column :real_banners, :show_time, :time_from
  end
end
