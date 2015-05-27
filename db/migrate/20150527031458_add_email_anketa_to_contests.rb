class AddEmailAnketaToContests < ActiveRecord::Migration
  def change
    add_column :contests, :email, :string
    add_column :contests, :anketa_content, :text

    add_column :works, :anketa, :text
  end
end
