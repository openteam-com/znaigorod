# encoding: utf-8

class ReviewObserver < ActiveRecord::Observer
  def after_save(review)
    return unless review.published?

    review.delay(:queue => 'critical').upload_poster_to_vk if (review.poster_vk_id.nil? || review.poster_url_changed?) && review.has_poster?
  end

  def after_to_published(review, transition)
    review.index!

    MyMailer.delay(:queue => 'mailer').mail_new_published_review(review) unless review.account.users.first.roles.any?
    Feed.create(:feedable => review, :account => review.account, :created_at => review.created_at, :updated_at => review.updated_at)
  end

  def after_to_draft(review, transition)
    NotificationMessage.delay(:queue => 'critical')
      .create(:account => review.account, :kind => :post_returned, :messageable => review) unless review.account.is_admin?
  end
end
