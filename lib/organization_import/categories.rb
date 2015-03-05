module OrganizationImport
  class Categories
    attr_accessor :yml_path

    def initialize(yml_path = '/home/koala/Downloads/organization_categories.yml')
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
        title = data.try(:[], 'title') || csv_title

        if data && data['old_title']
          category = OrganizationCategory.find_by_title(data['old_title'])

          category.update_attributes :title => title, :parent => parent if category
        else
          category = parent ? parent.children.find_or_create_by_title!(title) : OrganizationCategory.find_or_create_by_title(title)
        end

        create_categories(data.try(:[], 'subcategories'), category)
      end
    end

    def category_by(title)
      p title
      hash = yml.flat_map { |k, v| v['subcategories'] }.inject({}) do |h, e|
        e.each { |k, v| h[k] = v.try(:[], 'title') }

        h
      end

      array = hash.detect { |k, _| k == title }
      raise array.inspect

      array ? OrganizationCategory.find_by_title(array.last || array.first) : nil
    end
  end
end
