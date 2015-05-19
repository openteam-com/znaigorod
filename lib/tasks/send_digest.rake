require 'optparse'
require_relative '../../app/workers/personal_digest_worker'
require_relative '../../app/workers/site_digest_worker'
require_relative '../../app/workers/statistics_digest_worker'

namespace :send_digest do

  desc 'Delivers digest to users'

  def accounts_form_env
    accounts = []
    args = ENV['accounts'].split(',').map(&:squish)
    args.each do |account_id|
      begin
        account = Account.find(account_id)
        accounts << account if account.present? && account.email.present?
      rescue
      end
    end

    accounts
  end

  desc "Send by email personal digest to users"
  task :personal => :environment do
    puts "Sending of personal digest. Please wait..."
    visit_period = 1.day
    if ENV['accounts'].present?
      accounts = accounts_form_env
    else
      accounts = Account.with_email.with_personal_digest.where('last_visit_at <= ?', Time.zone.now - visit_period) - Role.all.map(&:user).map(&:account).uniq
    end
    accounts.each do |account|
      PersonalDigestWorker.perform_async(account.id)
    end
  end

  desc "Send by email site digest to users"
  task :site => :environment do
    puts "Sending of site digest. Please wait..."

    visit_period = 1.day
    accounts = Account.with_email.with_site_digest.where('last_visit_at <= ?', Time.zone.now - visit_period) - Role.all.map(&:user).map(&:account).uniq
    SiteDigestWorker.perform_async(accounts.map(&:id))
  end

  desc "Send by email afisha and discout statistics to users"
  task :statistics => :environment do
    puts "Sending of the afisha and discounts statistics digest. Please wait..."
    if ENV['accounts'].present?
      accounts = accounts_form_env
    else
      accounts = Account.with_email.with_statistics_digest - Role.all.map(&:user).map(&:account).uniq + Account.where(id: 2303)
    end
    accounts.each do |account|
      StatisticsDigestWorker.perform_async(account.id)
    end
  end

end
