namespace :categories do
  desc 'Import categories from YML=(/path/to/yml)'
  task :import_from_yml => :environment do
    if ENV['YML']
      OrganizationImport::Categories.new(ENV['YML']).import
    else
      puts 'Usage rake organizations:import_categories YML=/path/to/yml'
    end
  end
end

namespace :organizations do
  desc 'Update SLUGS'
  task :update_slugs => :environment do
    YAML.load_file(ENV['YML']).each do |key, value|
      OrganizationCategory.find(value).update_attribute(:slug, key)
    end
  end

  desc 'Add features from YML'
  task :add_features => :environment do
    YAML.load_file(ENV['YML']).each do |key, value|
      org_category = OrganizationCategory.where(slug: key).first
      if org_category
        value['features'].map{ |feature| org_category.features.create(title: feature.capitalized) } if value['features']
        value['offers'].map{ |offer| org_category.features.create(title: offer.capitalized) } if value['offers']
      end
    end

    Organization.all.each { |org| org.features += OrganizationImport::Features.new(org.feature).features }
    Organization.all.each { |org| org.features += OrganizationImport::Features.new(org.offer).features }
  end

  desc 'Import organizations from 2gis CSV=(/path/to/csv) YML=(/path/to/yml)'
  task :import_from_csv => :environment do
    if ENV['CSV'] && ENV['YML']
      OrganizationImport::Categories.new(ENV['YML']).import

      Organization.all.each { |org| org.features += OrganizationImport::Features.new(org.feature).features }

      OrganizationImport::Organizations.new(ENV['CSV'], ENV['YML']).create_organizations

      OrganizationImport::OrganizationsCategoriesLinker.new.set_categories_for_organizations_with_suborganizations
    else
      puts 'Usage rake organizations:import_from_csv CSV=/path/to/csv YML=/path/to/yml'
    end
  end

  desc 'Find unmatched organization'
  task :find_unmatched => :environment do
    if ENV['CSV'] && ENV['YML']
      OrganizationImport::Categories.new(ENV['YML']).import

      OrganizationImport::Organizations.new(ENV['CSV'], ENV['YML']).find_unmatched
    else
      puts 'Usage rake organizations:find_unmatched CSV=/path/to/csv YML=/path/to/yml'
    end
  end

  desc 'Find similar organization'
  task :find_similar => :environment do
    if ENV['CSV'] && ENV['YML']
      OrganizationImport::Categories.new(ENV['YML']).import

      OrganizationImport::Organizations.new(ENV['CSV'], ENV['YML']).find_similar
    else
      puts 'Usage rake organizations:find_unmatched CSV=/path/to/csv YML=/path/to/yml'
    end
  end
end

