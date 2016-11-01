class AddPosterUrlToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :poster_url, :text
  end
end
