require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
require "csv"

# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Znaigorod
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir.glob(Rails.root.join('app/models/*')).select { |f| File.directory? f }
    config.autoload_paths += %W(
                                #{config.root}/app/presenters
                                #{config.root}/app/presenters/afisha
                                #{config.root}/app/presenters/suborganizations
                                #{config.root}/lib
                               )

    config.paths['config/routes'] += Dir[Rails.root.join('config', 'routes', '*.rb')].sort
    config.action_controller.asset_host = Settings['app']['url']

    config.log_level = :debug

    config.exceptions_app = self.routes

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    observers = Dir.glob(Rails.root.join('app/models/observers/*_observer.rb'))
      .map { |file_name| file_name.split('/').last.gsub('.rb', '').to_sym }

    config.active_record.observers = observers

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    raise 'Where am i?' unless Settings['app.timezone'].present?
    config.time_zone = Settings['app.timezone']

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru

    I18n.enforce_available_locales = false

    config.middleware.insert_before "Rack::Runtime", Rack::UTF8Sanitizer

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:code, :password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.to_prepare do
      Dir[Rails.root.join('app/models/*/*.rb')].each do |model_path|
        require_or_load model_path.to_s
      end
    end

    config.action_mailer.default_url_options = { :host => Settings['app.host'], :port => Settings['app.port']}

    config.assets.paths << Rails.root.join("app", "assets", "docs")
    config.assets.paths << Rails.root.join("app", "assets", "flash")
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.generators do |generators|
      generators.assets               false
      generators.helper               false
      generators.stylesheets          false

      generators.test_framework       :rspec

      generators.fixture_replacement  false

      generators.controller_specs     false
      generators.helper_specs         false
      generators.routing_specs        false
      generators.view_specs           false
    end
  end
end
