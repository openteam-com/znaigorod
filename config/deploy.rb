require 'openteam/capistrano/recipes'
require 'sidekiq/capistrano'

namespace :sitemap do
  desc 'Create symlinks to sitemap.xml and sitemap.xml.gz'
  task :symlinks, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/sitemaps/sitemap.xml #{deploy_to}/current/public/sitemap.xml"
    run "ln -nfs #{shared_path}/sitemaps/sitemap.xml.gz #{deploy_to}/current/public/sitemap.xml.gz"
  end
  after 'deploy:create_symlink', 'sitemap:symlinks'
end

namespace :robots do
  desc 'Create symlinks for robots.txt'
  task :symlinks, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/robots.txt #{deploy_to}/current/public/robots.txt"
  end
  after 'deploy:create_symlink', 'robots:symlinks'
end

set :shared_children, fetch(:shared_children) + %w[config/sape.yml sape public/yandex]
