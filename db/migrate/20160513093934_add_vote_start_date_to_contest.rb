class AddVoteStartDateToContest < ActiveRecord::Migration
  def change
    add_column :contests, :vote_start_at, :datetime

    Contest.update_all(vote_start_at: DateTime.now)
  end
end
