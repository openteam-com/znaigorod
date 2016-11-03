class AddCommentToFullSchedules < ActiveRecord::Migration
  def change
    add_column :full_schedules, :comment, :text
  end
end
