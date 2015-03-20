module OrganizationImport
  class Features
    attr_accessor :feature_string

    def initialize(feature_string = nil)
      @feature_string = feature_string
    end

    def feature_titles
      (feature_string || '').split(',').delete_if(&:blank?).map(&:mb_chars).map(&:squish).map(&:capitalized).map(&:to_s)
    end

    def features
      Feature.where :title => feature_titles
    end
  end
end
