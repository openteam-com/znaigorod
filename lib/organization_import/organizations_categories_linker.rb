module OrganizationImport
  class OrganizationsCategoriesLinker
    def normalize_title(title)
      title.mb_chars.downcase.capitalize
    end

    def set_categories_for_organizations_with_suborganizations
      Organization.basic_suborganization_kinds.each do |kind|
        category_title = normalize_title(I18n.t("organization.kind.#{kind}"))
        category = OrganizationCategory.find_by_title!(category_title)

        kind.classify.constantize.includes(:organization).each do |suborg|
          suborg.categories.each do |title|
            c = category.subtree.where(:title => normalize_title(title)).first

            suborg.organization.organization_categories += [c] if c
          end

          if suborg.categories.empty?
            category_title = normalize_title(I18n.t("organization.kind.#{kind}"))
            category = OrganizationCategory.find_by_title!(category_title)

            suborg.organization.organization_categories += [category]
          end

          suborg.organization.index
        end
      end
    end
  end
end

