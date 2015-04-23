require File.expand_path('../directories.rb', __FILE__)
require 'configliere'

dir = Directories.new

if RUBY_PLATFORM =~ /freebsd/
  set :job_template, "/usr/local/bin/bash -l -i -c ':job' 1>#{dir.log('schedule.log')} 2>#{dir.log('schedule-errors.log')}"
else
  set :job_template, "/bin/bash -l -i -c ':job' 1>#{dir.log('schedule.log')} 2>#{dir.log('schedule-errors.log')}"
end

if false
  # ------------------------------------------

  # tasks run one time at week
  every :monday, :at => '6:30 am' do
    rake 'generate_yandex_companies_xml_files'
  end

  # ------------------------------------------

  # everyday tasks

  every :day, :at => '3:00 am' do
    rake 'update_rating:all'
  end

  every :day, :at => '3:30 am' do
    rake 'organization:update_positive_activity_date'
  end

  every :day, :at => '4:00 am' do
    rake 'social_likes'
  end

  every :day, :at => '6:30 am' do
    rake 'send_digest:statistics'
  end

  every :day, :at => '7:15 am' do
    rake 'sync:fakel'
  end

  every :day, :at => '7:20 am' do
    rake 'sync:kinomax'
  end

  every :day, :at => '7:25 am' do
    rake 'sync:kinomir'
  end

  every :day, :at => '7:30 am' do
    rake 'sync:goodwin'
  end

  every :day, :at => '7:35 am' do
    rake 'sync:kinopolis'
  end

  # ------------------------------------------

  # recurring tasks

  every 30.minutes do
    rake 'refresh_copies'
    rake 'kill_offers'
  end

  every 6.hours do
    #rake 'afisha:event_users'
    rake 'actualize_discounts'
    rake 'update_ponominalu_tickets'
  end

  # ------------------------------------------

  # Commented for future

  #every :thursday, :at => '8:00 am' do
  #rake 'send_digest:site'
  #end

  #every :day, :at => '6:00 am' do
  #rake 'send_digest:personal'
  #rake 'generate_yandex_companies_xml_files'
  #end

  #every 6.hours do
  #rake 'sitemap:refresh refresh_sitemaps'
  #end

  #every :day, :at => '5am' do
  #rake 'account:get_friends'
  #rake 'invitations:destroy_irrelevant'
  #end

  #every 3.hours do
  #rake 'balance_notify'
  #end

  #every 15.minutes do
  #rake 'get_sape_links'
  #end
end
