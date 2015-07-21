class AddThemeFieldToContest < ActiveRecord::Migration
  def change
    add_column :contests, :subject, :string
  end
end
