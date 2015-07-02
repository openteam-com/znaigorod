module OrganizationImport
  class SimilarOrganizations
    attr_accessor :title, :street, :house, :csv_id

    def initialize(title, street, house, csv_id)
      @title = title
      @street = street
      @house = house
      @csv_id = csv_id
    end

    def splited_street(s)
      s.split(/\.|\s/) rescue []
    end

    def searched
      @searched ||= Organization.where(:gis_title => title)
    end

    def csv_id_matched?(org)
      org.csv_id.blank? || org.csv_id.to_s == csv_id.to_s
    end


    def street_matched?(org)
      (splited_street(org.address.try(:street)) & splited_street(street)).any?
    end

    def house_matched?(org)
      org.address.try(:house).try(:squish).try(:mb_chars).try(:downcase) == house.squish.mb_chars.downcase
    end

    def address_matched?(org)
      street_matched?(org) && house_matched?(org)
    end

    def not_matched_reason
      return :title if searched.empty?
      return :address if selected.empty?
    end

    def searched_limited
      searched.select { |o| csv_id_matched?(o) }
    end

    def selected
      @selected ||= searched_limited.select { |o| address_matched?(o) }
    end

    def address_empty?
      street.blank? && house.blank?
    end

    def results
      address_empty? ? searched_limited : selected
    end
  end
end

