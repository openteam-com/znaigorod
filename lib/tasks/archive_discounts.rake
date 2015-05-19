require 'progress_bar'
namespace :discounts do
  desc 'Archive discounts'
  task :archive_discounts => :environment do
    grouped_discounts = Discount.where(state: :published).group_by(&:account_id)
    pb = ProgressBar.new(grouped_discounts.count)
    counter = 0

    grouped_discounts.each do |account_id, discounts|
      archive_discounts = discounts.delete_if { |discount| discount.published_at + 1.month > Time.zone.now }
      archive_discounts.each do |discount|
        discount.delay(:queue => :critical).to_archive
        discount.update_attribute :promoted_at, nil
      end

      if account_id.present?
        account = Account.find(account_id)
        if archive_discounts.present? && account && account.has_email?
          counter += 1
          ArchiveDiscount.delay(:queue => :mailer, :retry => false).send_archived(account, archive_discounts)
          break if Rails.env.development?
        end
      end
      pb.increment!
    end
    p "Mails with archived discounts info - #{counter}"
  end

  desc 'Warning for discount owner'
  task :archive_warning => :environment do
    grouped_discounts = Discount.where(state: :published).group_by(&:account_id)
    pb = ProgressBar.new(grouped_discounts.count)
    counter = 0

    grouped_discounts.each do |account_id, discounts|
      if account_id.present?
        account = Account.find(account_id)
        archive_discounts = discounts.delete_if { |discount| discount.published_at + 1.month - 3.days > Time.zone.now }

        if archive_discounts.present? && account && account.has_email?
          counter += 1
          ArchiveDiscount.delay(:queue => :mailer, :retry => false).send_warning(account, archive_discounts)
          break if Rails.env.development?
        end
      end
      pb.increment!
    end
    p "Mails with archive warning information - #{counter}"
  end
end
