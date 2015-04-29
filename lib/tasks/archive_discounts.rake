require 'progress_bar'
namespace :discounts do
  desc 'Archive discounts'
  task :archive_discounts => :environment do
    discounts = Discount.where(state: :published)
    pb = ProgressBar.new(discounts.count)

    discounts.each do |discount|
      discount.to_archive if discount.published_at + 1.month < Time.zone.now
      pb.increment!
    end
  end

  desc 'Warning for discount owner'
  task :archive_warning => :environment do
    discounts = Discount.where(state: :published)
    pb = ProgressBar.new(discounts.count)

    discounts.each do |discount|
      if discount.published_at + 1.month - 3.days < Time.zone.now && discount.published_at >= Time.zone.now.beginning_of_year
        ArchiveDiscount.delay(:queue => :mailer).send_info(discount) if discount.account && discount.account.has_email?
      end
      pb.increment!
    end
  end
end
