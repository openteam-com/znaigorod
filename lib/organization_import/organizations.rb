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

          similar = SimilarOrganizations.new(csv_rows.first.title, csv_address.street, csv_address.house, id)

          array += similar.results
        end

        pb.increment!
      end

      results = Organization.joins(:organization_categories).where(:organization_categories => { :id => categories_from_yml.subcategories_for_import.pluck(:id) }).uniq - array
      if results.any?
        results.each do |o|
          puts "#{o.title};#{o.address};http://znaigorod.ru/manage/organizations/#{o.slug}"
        end
      else
        puts 'Ничего не найдено.'
      end
    end

    def splited_street(s)
      s.split(/\.|\s/).delete_if(&:blank?) rescue []
    end

    def street_matched?(org1, org2)
      (splited_street(org1.address.try(:street)) & splited_street(org2.address.try(:street))).any?
    end

    def house_matched?(org1, org2)
      org1.address.try(:house).try(:squish).try(:mb_chars).try(:downcase) == org2.address.try(:house).try(:squish).try(:mb_chars).try(:downcase)
    end

    def address_matched?(org1, org2)
      street_matched?(org1, org2) && house_matched?(org1, org2)
    end

    def find_similar
      hash = {}
      pb = ProgressBar.new(Organization.count)
      Organization.find_each do |org|
        results = Organization.search { keywords(org.title) }.results
          .delete_if { |o| o == org }
          .delete_if { |o| !address_matched?(o, org) }
        hash[org] = results if results.any?
        pb.increment!
      end

      hash.each do |key, value|
        puts "#{key.title}; #{key.address}; http://znaigorod.ru/manage/organizations/#{key.slug};"
        puts "Возможные совпадения;"
        value.each do |org|
          puts "#{org.title}; #{org.address}; http://znaigorod.ru/manage/organizations/#{org.slug};"
        end
        puts "<<<<<<<<<<<<<<<<<<<;"
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
              if raw_address
                address = organization.address.nil? ? Address.new : organization.address
                address.street = csv_address.street
                address.house = csv_address.house
                address.office = csv_address.office
                address.city = csv_rows.first.city
                address.latitude = csv_rows.first.latitude.gsub(',','.')
                address.longitude = csv_rows.first.longitude.gsub(',','.')
                address.save(:validate => false)
                organization.address = address
              end

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
