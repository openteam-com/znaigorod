require 'progress_bar'
class Add2GisTitleToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :gis_title, :string

    Organization.reset_column_information
    pb = ProgressBar.new(Organization.count)

    Organization.find_each do |org|
      org.update_attribute(:gis_title ,org.title)
      pb.increment!
    end
  end
end
