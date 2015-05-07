# encoding: utf-8

require 'progress_bar'

namespace :organization do

  desc 'Upload posters to vkontakte'
  task :posters_to_vk => :environment do
    puts 'Upload organization posters to vkontakte'
    organizations = Organization.where('logotype_url is not null') - Organization.where(logotype_url: "")
    bar = ProgressBar.new(organizations.count)
    organizations.each do |organization|
      organization.upload_poster_to_vk
      bar.increment!
    end
  end

  desc 'Обновление positive_activity_date у организаций'
  task :update_positive_activity_date => :environment do
    organizations = Organization.search { with :status, [:client_standart, :client_premium] }.results
    bar = ProgressBar.new(organizations.count)
    organizations.each do |organization|
      if organization.positive_activity_date && (organization.positive_activity_date < Time.zone.now - 7.days)
        organization.update_attribute :positive_activity_date, Time.zone.now
      end

      bar.increment!
    end
  end

  desc 'Обновление positive_activity_date у организаций с пакетом эконом'
  task :update_positive_activity_date_economy => :environment do
    organizations = Organization.search { with :status, [:client_economy] }.results
    bar = ProgressBar.new(organizations.count)
    organizations.each do |organization|
      if organization.positive_activity_date && (organization.positive_activity_date < Time.zone.now - 1.month)
        organization.update_attribute :positive_activity_date, Time.zone.now
      end

      bar.increment!
    end
  end
end

