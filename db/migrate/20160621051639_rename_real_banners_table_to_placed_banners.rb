class RenameRealBannersTableToPlacedBanners < ActiveRecord::Migration
  def change
    rename_table :real_banners, :placed_banners
  end
end
