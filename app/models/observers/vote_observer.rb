# encoding: utf-8

class VoteObserver < ActiveRecord::Observer
  def after_create(vote)
    if vote.voteable.is_a?(Afisha) && vote.voteable.user.present? && vote.user.present? && vote.voteable.user != vote.user
      NotificationMessage.delay.create(
        account: vote.voteable.user.account,
        producer: vote.user.account,
        kind: :user_vote_afisha,
        messageable: vote)
    elsif vote.voteable.is_a?(Comment) && vote.voteable.user != vote.user
      NotificationMessage.delay.create(
        account: vote.voteable.user.account,
        producer: vote.user.account,
        kind: :user_vote_comment,
        messageable: vote)
    end
  end

  def after_save(vote)
    #vote.user.account.delay.update_rating if vote.user.present? && vote.user.account.present?
    #vote.voteable.delay.update_rating if vote.voteable.respond_to?(:update_rating)
    #vote.voteable.user.account.delay.update_rating if vote.voteable.respond_to?(:user) && vote.voteable.user && vote.voteable.user.account
  end
end
