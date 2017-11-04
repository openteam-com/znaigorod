# encoding: utf-8

require 'progress_bar'

namespace :organization do

  desc 'Delete old tariffs from organization'
  task :old_tariffs => :environment do
    organization_tariffs = OrganizationTariff.all
    bar = ProgressBar.new(organization_tariffs.count)
    count_deleted = 0
    organization_tariffs.each do |o_t|
      duration = case o_t.duration
                 when 'month'
                   1.month
                 when 'six_months'
                   6.months
                 when 'year'
                   1.year
                 end.to_i
      if Time.now - o_t.created_at > duration
        o_t.destroy
        count_deleted+=1
      end
      bar.increment!
    end
    p "Было удалено #{count_deleted} старых тарифов!" if count_deleted > 0
  end

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
      unless organization.positive_activity_date
        organization.update_attribute :positive_activity_date, Time.zone.now
      else
        if organization.positive_activity_date < Time.zone.now - 1.month
          organization.update_attribute :positive_activity_date, Time.zone.now
        end
      end

      bar.increment!
    end
  end
end
