require 'progress_bar'

module OrganizationImport
  class Organizations
    attr_accessor :csv_path

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def csv_data
      @csv_rows ||= begin
                      #start = 1#2608#31839
                      #finish = -1#2641#31841

                      #CSV.read(csv_path, :col_sep => ';')[start..finish]
                      array = CSV.read(csv_path, :col_sep => ';')
                    end
    end

    def unique_ids
      @unique_ids ||= csv_data.map { |r| r[1] }.compact.uniq
    end

    def csv_rows_by(id)
      csv_data.select { |r| r[1] == id }.map { |r| CsvRow.new r }
    end

    def splited_street(street)
      street.split(/\.|\s/) rescue []
    end

    def similar_organizations(title, street, house)
      orgs = Organization.search(:include => :address) { keywords title, :fields => :title_ru; paginate(:page => 1, :per_page => 1_000) }.results

      if street =~ /Иркутский тракт/ && title == "Банкомат, Сбербанк России, ОАО, Томское отделение №8616"
        p orgs
        p orgs.select { |o|
          (splited_street(o.address.try(:street)) & splited_street(street)).any? && (o.address.try(:house).try(:squish).try(:mb_chars).try(:downcase) == house.squish.mb_chars.downcase)
        }
      end

      if street.blank? && house.blank?
        orgs
      else
        orgs.select { |o|
          (splited_street(o.address.try(:street)) & splited_street(street)).any? && (o.address.try(:house).try(:squish).try(:mb_chars).try(:downcase) == house.squish.mb_chars.downcase)
        }
      end
    end

    def check
      pb = ProgressBar.new(unique_ids.count)
      hash = {}
      unique_ids.each do |id|
        csv_rows_by(id).group_by(&:address).each do |address, csv_rows|
          csv_address = CsvAddress.new(address)
          orgs = similar_organizations(csv_rows.first.title.split(',').first, csv_address.street, csv_address.house)

          if orgs.any?
            hash_key = SecureRandom.hex(4)
            hash[hash_key] = orgs
          end

        end
        pb.increment!
      end
      hash
    end

    def create_organizations
      pb = ProgressBar.new(unique_ids.count)

      unique_ids.each do |id|
        csv_rows_by(id).group_by(&:address).each do |raw_address, csv_rows|

          categories = csv_rows.map{ |csv_row| Categories.new.category_by(csv_row.category_title) }.compact

          if categories.any?
            csv_address = CsvAddress.new(raw_address)
            possible_organizations = similar_organizations(csv_rows.first.title, csv_address.street, csv_address.house)

            organization = if possible_organizations.any?
                             #puts "OLD - #{csv_rows.first.title}, #{raw_address}"
                             possible_organizations.first
                           else
                             puts "NEW - #{csv_rows.first.title}, #{raw_address}"
                             Organization.new
                           end

            # organization
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
            features = csv_rows.map{ |feature| Categories.new.feature_by(feature.category_title) }.compact
            organization.features += features
            csv_rows.each { |csv_row| organization.features += Features.new(csv_row.extra).features }

            if raw_address == "Иркутский тракт, 175а" && csv_rows.first.title == "Банкомат, Сбербанк России, ОАО, Томское отделение №8616"
              p '>'*80
              p possible_organizations
              p organization
            end
          else
            next
          end
        end

        pb.increment!
      end
    end
  end
end
