module OrganizationImport
  class Categories
    attr_accessor :yml_path

    def initialize(yml_path)
      @yml_path = yml_path
    end

    def yml
      @yml ||= begin
                 YAML.load_file(yml_path)['categories']
               end
    end

    def create_categories(hash = yml, parent = nil)
      return unless hash

      hash.each do |csv_title, data|
        title = (data.try(:[], 'title') || csv_title).capitalized

        category = nil
        if data.try(:[], 'old_title')
          category = OrganizationCategory.find_by_title(data['old_title'].capitalized)

          category ?
            category.update_attributes(:title => title, :parent => parent) :
            category = OrganizationCategory.find_by_title(title) # для повторного импорта когда уже нет категории с old_title
        else
          category = if parent
                       child = parent.children.find_by_title(title)

                       if child
                         child.update_attributes(:title => title)
                       else
                         child = OrganizationCategory.find_or_create_by_title(title)
                         child.update_attributes(:parent => parent)
                       end

                       child
                     else
                       OrganizationCategory.find_or_create_by_title(title)
                     end
        end

        if data.try(:[], 'offers').try(:any?)
          data['offers'].each do |csv_title, title|
            category.features.find_or_create_by_title((title || csv_title).capitalized)
          end
        end

        create_categories(data.try(:[], 'subcategories'), category)
      end
    end

    def category_by(title)
      hash = yml.flat_map { |k, v| v['subcategories'] }.inject({}) do |h, e|
        e.each { |k, v| h[k] = v.try(:[], 'title') }

        h
      end

      array = hash.detect { |k, _| k == title }

      array ? OrganizationCategory.find_by_title((array.last || array.first).capitalized) : nil
    end

    def feature_by(title)
      hash = yml.flat_map { |k, v| v['subcategories'] }.inject({}) do |h, e|
        e.each { |k, v| h[k] = v.try(:[], 'offers') }

        h
      end

      hash = Hash[hash.values.compact.map(&:to_a).inject([]) { |res, arr| arr.each { |e| res << e }; res }]

      array = hash.detect { |k, _| k == title }

      array ? Feature.find_by_title(array.last || array.first) : nil
    end

    def root_category_titles_for_import
      yml.keys
    end

    def subcategories_for_import
      hash = yml.flat_map { |k, v| v['subcategories'] }.inject({}) do |h, e|
        e.each { |k, v| h[k] = v.try(:[], 'title') }

        h
      end

      OrganizationCategory.where :title => hash.map { |k, v| v ? v : k }
    end
  end
end
