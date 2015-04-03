require 'progress_bar'

module OrganizationImport
  Organization.class_eval do
    def should_generate_new_friendly_id?
      true
    end
  end

  class Organizations
    attr_accessor :csv_path, :yml_path

    def initialize(csv_path, yml_path)
      @csv_path = csv_path
      @yml_path = yml_path
    end

    def categories_from_yml
      @categories_from_yml ||= Categories.new(yml_path)
    end

    def limited_csv_data
      @limited_csv_data ||= CSV.read(csv_path, :col_sep => ';').select { |r| categories_from_yml.root_category_titles_for_import.include? r[4] }
    end

    def unique_ids
      @unique_ids ||= limited_csv_data.map { |r| r[1] }.compact.uniq
    end

    def csv_rows_by(id)
      limited_csv_data.select { |r| r[1] == id }.map { |r| CsvRow.new r }
    end

    def find_unmatched
      pb = ProgressBar.new(unique_ids.count)

      array = []

      unique_ids.each do |id|
        csv_rows_by(id).group_by(&:address).each do |address, csv_rows|
          csv_address = CsvAddress.new(address)

          title_for_similar = csv_rows.first.title.split(',').first
          similar = SimilarOrganizations.new(title_for_similar, csv_address.street, csv_address.house, id)

          array += similar.results
        end

        pb.increment!
      end

      results = Organization.joins(:organization_categories).where(:organization_categories => { :id => categories_from_yml.subcategories_for_import.pluck(:id) }).uniq - array
      results.each do |o|
        puts "#{o.title};#{o.address};http://znaigorod.ru/manage/organizations/#{o.slug}"
      end
    end

    def create_organizations
      pb = ProgressBar.new(unique_ids.count)

      statistics = { :create => 0, :update => 0, :non_existing_categories => [] }

      ActiveRecord::Base.transaction do
        unique_ids.each do |id|
          csv_rows_by(id).group_by(&:address).each do |raw_address, csv_rows|
            categories = csv_rows.map { |csv_row| categories_from_yml.category_by(csv_row.category_title) }.compact
            categories += csv_rows.map { |csv_row| categories_from_yml.feature_by(csv_row.category_title) }.compact.map(&:organization_category)

            categories.uniq!

            csv_address = CsvAddress.new(raw_address)

            if categories.any?
              title_for_similar = csv_rows.first.title.split(',').first

              possible_organizations = SimilarOrganizations.new(title_for_similar, csv_address.street, csv_address.house, id).results

              # organization
              organization = possible_organizations.any? ? possible_organizations.first : Organization.new
              organization.new_record? ? statistics[:create] += 1 : statistics[:update] += 1

              organization.csv_id = id
              organization.title = csv_rows.first.title
              organization.email = csv_rows.map(&:email).compact.uniq.first
              organization.phone = csv_rows.map(&:phone).compact.uniq.first
              organization.site = csv_rows.map(&:site).compact.uniq.first

              # address
              address = organization.address.nil? ? Address.new : organization.address
              address.street = csv_address.street
              address.house = csv_address.house
              address.office = csv_address.office
              address.city = csv_rows.first.city
              address.latitude = csv_rows.first.latitude
              address.longitude = csv_rows.first.longitude
              address.save(:validate => false)
              organization.address = address

              # force generate slug
              organization.send :set_slug unless organization.slug?
              organization.save(:validate => false)

              # categories
              organization.organization_categories += categories

              # features
              features = csv_rows.map { |feature| categories_from_yml.feature_by(feature.category_title) }.compact
              extra_features = csv_rows.flat_map { |csv_row| Features.new(csv_row.extra).features }.uniq

              organization.features += features
              organization.features += extra_features
            else
              statistics[:non_existing_categories] += csv_rows.map(&:category_title)

              next
            end
          end

          pb.increment!
        end
      end

      puts "Create #{statistics[:create]} organizations"
      puts "Update #{statistics[:update]} organizations"
      puts "Non existing categories #{statistics[:non_existing_categories].uniq.sort.join(', ')}"
    end
  end
end
