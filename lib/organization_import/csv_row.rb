module OrganizationImport
  class CsvRow
    attr_accessor :row

    def initialize(row)
      @row = row
    end

    def id
      row[1]
    end

    def title
      row[2]
    end

    def category_title
      row[5]
    end

    def latitude
      row[9]
    end

    def longitude
      row[8]
    end

    def address
      row[7]
    end

    def phone
      row[15]
    end

    def email
      row[14]
    end

    def site
      row[17]
    end

    def city
      row[6]
    end

    def extra
      row[19]
    end
  end
end
