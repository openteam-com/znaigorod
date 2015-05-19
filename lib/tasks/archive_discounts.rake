require 'progress_bar'
namespace :discounts do
  desc 'Archive discounts'
  task :archive_discounts => :environment do
    grouped_discounts = Discount.where(state: :published).group_by(&:account_id)
    pb = ProgressBar.new(grouped_discounts.count)

    grouped_discounts.each do |account_id, discounts|
      account = Account.find(account_id)
      archive_discounts = discounts.delete_if{ |discount| discount.published_at + 1.month > Time.zone.now }
      archive_discounts.each do |discount|
        discount.to_archive
        discount.update_attribute :promoted_at, nil
      end

      if archive_discounts.present? && account && account.has_email?
        ArchiveDiscount.delay(:queue => :mailer, :retry => false).send_archived(account, archive_discounts)
        break if Rails.env.development?
      end
      pb.increment!
    end
  end

  desc 'Warning for discount owner'
  task :archive_warning => :environment do
    grouped_discounts = Discount.where(state: :published).group_by(&:account_id)
    pb = ProgressBar.new(grouped_discounts.count)

    grouped_discounts.each do |account_id, discounts|
      account = Account.find(account_id)
      archive_discounts = discounts.delete_if{ |discount| discount.published_at + 1.month - 3.days > Time.zone.now }

      if archive_discounts.present? && account && account.has_email?
        ArchiveDiscount.delay(:queue => :mailer, :retry => false).send_warning(account, archive_discounts)
        break if Rails.env.development?
      end
      pb.increment!
    end
  end
end
