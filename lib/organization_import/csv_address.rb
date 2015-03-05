module OrganizationImport
  class CsvAddress
    attr_accessor :address

    def initialize(address)
      @address = address
    end

    def splited
      (address || '').split(',').map(&:squish)
    end

    def street
      splited.first
    end

    def house
      (splited.second || '').split('-').map(&:squish).first
    end

    def office
      office = (address || '').split('-').map(&:squish)
      office.count >1 ? office.second : nil
    end
  end
end
