require 'progress_bar'

module OrganizationImport
  class Organizations
    attr_accessor :csv_path, :yml_path

    def initialize(csv_path, yml_path)
      @csv_path = csv_path
      @yml_path = yml_path
    end

    def categories_from_yml
      @categories_from_yml ||= Categories.new(yml_path)
    end

    def categories_for_import
      @categories_for_import ||= categories_from_yml.categories_for_import
    end

    def csv_data
      @csv_data ||= CSV.read(csv_path, :col_sep => ';').select { |r| categories_for_import.include? r[4] }
    end

    def unique_ids
      @unique_ids ||= csv_data.map { |r| r[1] }.compact.uniq
    end

    def csv_rows_by(id)
      csv_data.select { |r| r[1] == id }.map { |r| CsvRow.new r }
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
              possible_organizations = SimilarOrganizations.new(csv_rows.first.title, csv_address.street, csv_address.house, id).results

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
