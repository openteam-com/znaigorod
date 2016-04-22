class MovieFixer < ActiveRecord::Base
  attr_accessible :from, :to

  normalize_attributes :from, :to
end
