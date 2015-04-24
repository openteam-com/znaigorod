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
end
