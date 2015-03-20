namespace :organizations do
  desc 'Connect organizations with features'
  task :connect_with_features => :environment do
    Organization.all.each { |org| org.features += OrganizationImport::Features.new(org.feature).features }
  end

  desc 'Import organizations from 2gis CSV=(/path/to/csv)'
  task :import_from_csv => :environment do
    if ENV['CSV']
      OrganizationImport::Categories.new.create_categories
      OrganizationImport::Organizations.new(ENV['CSV']).create_organizations
    else
      puts 'Usage rake organizations:import_from_csv CSV=/path/to/csv'
    end

  end
end

