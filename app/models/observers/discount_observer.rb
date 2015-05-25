# encoding: utf-8

class DiscountObserver < ActiveRecord::Observer
  def after_save(discount)
    return unless discount.published?

    discount.delay(:queue => 'critical').upload_poster_to_vk if (discount.poster_vk_id.nil? || discount.poster_url_changed?) && discount.poster_url?
  end

  def after_to_published(discount, transition)
    if discount.account.present?
      MyMailer.delay(:queue => 'mailer').mail_new_published_discount(discount) unless discount.account.users.first.roles.any?
      Feed.create(
        :feedable => discount,
        :account => discount.account,
        :created_at => discount.created_at,
        :updated_at => discount.updated_at
      )
    end
  end

  def after_to_draft(discount, transition)
    if discount.account.present?
      NotificationMessage.delay(:queue => 'critical').create(
        :account => discount.account,
        :kind => :discount_returned,
        :messageable => discount) unless discount.account.is_admin?
    end
  end
end
