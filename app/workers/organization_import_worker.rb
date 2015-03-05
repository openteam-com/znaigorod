class OrganizationImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :critical, :retry => false

  def perform(id)
    importer = OrganizationImport::Organizations.new
    importer.csv_rows_by(id).group_by(&:address).each do |address, csv_rows|
      csv_address = OrganizationImport::CsvAddress.new(address)
      {
        :address => csv_address,
        :title => csv_rows.first.title,
        :latitude => csv_rows.first.latitude,
        :longitude => csv_rows.first.longitude,
        :categories => csv_rows.map(&:category_title),
        :email => csv_rows.map(&:email).compact.uniq.first,
        :phone => csv_rows.map(&:phone).compact.uniq.first,
        :site => csv_rows.map(&:site).compact.uniq.first,
        :offer => [],
        :possible_organization => importer.similar_organizations(csv_rows.first.title, csv_address.street, csv_address.house)
      }
    end
  end
end
