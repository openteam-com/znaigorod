class CreateMovieFixers < ActiveRecord::Migration
  def change
    create_table :movie_fixers do |t|
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
