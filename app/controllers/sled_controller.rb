class SledController < ApplicationController
  def index
    not_in_contest = Account.find([37976])
    @accounts = Account.joins(:users).joins('LEFT JOIN roles ON users.id = roles.user_id').where('roles.user_id is null')
      .joins(:reviews).where('reviews.created_at > ?', Time.zone.parse("01.06.2015")).where('reviews.state = ?', "published").uniq
      .sort_by{ |account| account.sled_rating }.reverse - not_in_contest
  end
end
