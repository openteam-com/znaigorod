class AddColumnTargetToRealBanner < ActiveRecord::Migration
  def change
    add_column :real_banners, :target, :string
  end
end
