# encoding: utf-8

namespace :update_rating do

  desc "Обновление рейтинга пользователей"
  task :accounts => :environment do
    Account.actual.map(&:update_rating)
  end

  desc "Обновление рейтинга афиши"
  task :afisha => :environment do
    Afisha.actual.published.map(&:update_rating)
  end

  desc "Обновление рейтинга организаций"
  task :organizations => :environment do
    Organization.all.map(&:update_rating)
  end

  desc "Обновление рейтинга обзоров"
  task :reviews => :environment do
    Review.with_period.map(&:update_rating)
  end

  desc "Обновление рейтинга купонов"
  task :discounts => :environment do
    Discount.published.actual.map(&:update_rating)
  end

  desc "Обновление рейтинга работ"
  task :works => :environment do
    Work.all.map(&:update_rating)
  end

  desc "Обновление рейтинга"
  task :all => [:accounts, :afisha, :organizations, :reviews, :discounts, :works]
end
