require 'progress_bar'
require_relative '../../app/workers/organization_import_worker'

module OrganizationImport
  class Organizations
    attr_accessor :csv_path

    def initialize(csv_path = '/home/koala/Downloads/tomsk_utf_8.csv')
      @csv_path = csv_path
    end

    # TODO: not used
    def csv
      @csv ||= begin
                 hash = csv_data.map { |r| r[3] }.uniq.delete_if(&:blank?).sort!.inject({}) { |h, c| h[c] ||= {}; h }

                 data.inject(hash) do |h, r|
                   if r[3].present?
                     h[r[3]][r[4]] ||= []
                     h[r[3]][r[4]] << r[5]
                     h[r[3]][r[4]].uniq!
                   end

                   h
                 end
               end
    end

    def csv_data
      start = 1#2608#31839
      finish = -1#2641#31841
      csv_data ||= CSV.read(csv_path, :col_sep => ';')[start..finish]
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
      orgs = Organization.search(:include => :address) { keywords title.split(',').first, :fields => :title_ru; paginate(:page => 1, :per_page => 1_000) }.results

      orgs.select { |o|
        (splited_street(o.address.try(:street)) & splited_street(street)).any? && (o.address.try(:house).try(:squish) == house.squish)
      }
    end

    def check
      csv_data.inject({}) do |hash, row|
        csv_row = CsvRow.new(row)
        csv_address = CsvAddress.new(csv_row.address)
        orgs = similar_organizations(csv_row.title.split(',').first, csv_address.street, csv_address.house)

        if orgs.any?
          hash_key = SecureRandom.hex(4)
          hash[hash_key] = orgs
          #hash[hash_key][:csv_title] = csv_row.title
          #hash[hash_key][:csv_address] = csv_row.address
          #hash[hash_key][:organizations] = orgs.inject({}) { |h, o| h[:title] = o.title; h[:address] = o.address.try(:to_s); h }
        end

        hash
      end
    end

    def create_organizations
      pb= ProgressBar.new(unique_ids.count)
      unique_ids.each do |id|
        csv_rows_by(id).group_by(&:address).each do |address, csv_rows|
          p csv_rows.first.title
          csv_address = OrganizationImport::CsvAddress.new(address)
          possible_organizations = similar_organizations(csv_rows.first.title, csv_address.street, csv_address.house)
          address = Address.create(:street => csv_address.street, :house => csv_address.house, :office => csv_address.office,
                                  :city => csv_rows.first.city, :latitude => csv_rows.first.latitude, :longitude => csv_rows.first.longitude)

          categories = csv_rows.map{ |category| OrganizationImport::Categories.new.category_by(category.category_title) }.compact

          organization = possible_organizations.any? ? possible_organizations.first : organization = Organization.new

          organization.address = address
          organization.organization_categories = categories
          organization.title = csv_rows.first.title
          organization.email = csv_rows.map(&:email).compact.uniq.first
          organization.phone = csv_rows.map(&:phone).compact.uniq.first
          organization.site = csv_rows.map(&:site).compact.uniq.first
          organization.save(:validate => false)

        end
        pb.increment!
      end
    end
  end
end
