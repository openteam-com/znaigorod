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

  desc "Генерация базы email заведений"
  task :generate_emails => :environment do
    CSV.open("#{Rails.root}/public/orgs.csv", 'wb', :col_sep => ';') do |csv|
      csv << ['Организация', 'Email', 'Сферы']
      Organization.where("email != '' OR email is not null").each do |org|
        csv << [
          org.title,
          org.email,
          org.organization_categories.map(&:title).join(", ")
        ]
      end
    end
  end
end
