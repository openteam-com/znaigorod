class ChangeNilToPublished < ActiveRecord::Migration
  Organization.where(:state => nil).update_all(state: 'published')
end
