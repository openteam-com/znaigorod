class SledController < ApplicationController
  def index
    not_in_contest = Account.find([11])
    @accounts = Account.joins(:users).joins('LEFT JOIN roles ON users.id = roles.user_id').where('roles.user_id is null')
      .joins(:reviews).where('reviews.created_at > ?', Time.zone.parse("01.10.2015").beginning_of_day).where('reviews.state = ?', "published").uniq
      .sort_by{ |account| account.sled_rating }.reverse - not_in_contest
  end
end
