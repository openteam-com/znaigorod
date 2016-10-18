class CreateBreaks < ActiveRecord::Migration
  def change
    create_table :breaks do |t|
      t.time :from, :to
      t.belongs_to :full_schedule

      t.timestamps
    end
  end
end
