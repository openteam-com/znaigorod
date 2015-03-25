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

    def searched_orgs
      @searched_orgs ||= begin
                           search = Organization.search(:include => :address) do
                             keywords title, :fields => :title_ru
                             paginate :page => 1, :per_page => 1_000
                           end

                           search.results
                         end
    end

    def selected_orgs
      @selected_orgs ||= searched_orgs.select { |o|
        (!o.csv_id? || o.csv_id.to_s == csv_id.to_s) &&
          (splited_street(o.address.try(:street)) & splited_street(street)).any? &&
          (o.address.try(:house).try(:squish).try(:mb_chars).try(:downcase) == house.squish.mb_chars.downcase)
        }
    end

    def results
      #if street =~ /Междугородная/
        #p csv_id
        #puts '>'*80
        #puts "title = #{title.inspect} street = #{street.inspect} house = #{house.inspect}"
        #puts "count of searched orgs = #{searched_orgs.size}"
        #puts "count of selected_orgs = #{selected_orgs.size}"
      #end

      street.blank? && house.blank? ? searched_orgs : selected_orgs
    end
  end
end

