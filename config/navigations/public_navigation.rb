SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = Proc.new {|key| "main_menu_#{key}"}

  navigation.items do |primary|

    primary.item '23-february', 'День Защитника Отечества', february_path, highlights_on: -> { %w[map_projects map_layers].include? controller_name } do |february|
      MapProject.find('23-february').map_layers.each do |map_layer|
        february.item map_layer.slug, map_layer.title, february_path(layer: map_layer.slug)
      end
    end

    primary.item :afisha, 'Афиша', afisha_index_path, highlights_on: -> { controller_name == 'afishas' } do |afisha|

      Afisha.kind.values.each do |item|
        afisha.item "afisha_#{item}", I18n.t("enumerize.afisha.kind.#{item}") ,send("#{item.pluralize}_path")
      end
    end

    #primary.item :questions, 'Спрашивай', questions_path, highlights_on: -> { controller_name == 'questions' } do |questions|

      #Hash[Question.categories.options].invert.each do |category, title|
        #questions.item category, title, [:questions, category]
      #end
    #end

    primary.item :organizations, 'Заведения', organizations_path,
      highlights_on: -> { %w[organizations suborganizations saunas].include? controller.class.name.underscore.split("_").first } do |organization|

      Organization.suborganization_kinds_for_navigation.drop(1).each do |suborganization_kind|
        organization.item suborganization_kind, I18n.t("organization.kind.#{suborganization_kind}"), send("#{suborganization_kind.pluralize}_path"), :class => suborganization_kind  do |category|
          "#{suborganization_kind.pluralize}_presenter".camelize.constantize.new.categories_links.each do |link|
            category.item "#{suborganization_kind}_#{link[:klass]}", link[:title], send(link[:url])
          end
        end
      end
    end

    primary.item :discounts, 'Скидки', discounts_path, highlights_on: -> { controller_name == 'discounts' } do |discount|

      Hash[Discount.kind.options].invert.each do |kind, title|
        discount.item kind, title, [:discounts, kind]
      end
    end

    primary.item :reviews, 'Обзоры', reviews_path, highlights_on: -> { controller_name == 'reviews' } do |reviews|

      Hash[Review.categories.options].invert.each do |category, title|
        reviews.item category, title, [:reviews, category]
      end
    end

    primary.item :more, 'Ещё', '#', :link => { :class => :disabled },
      highlights_on: -> { %w[contests works cooperation].include?(controller_name) } do |more|

      more.item :questions, 'Спрашивай', questions_path, highlights_on: -> { controller_name == 'questions' }
      more.item :photogalleries, 'Фотостримы', photogalleries_path, highlights_on: -> { controller_name == 'photogalleries' }
      more.item :accounts, 'Знакомства', accounts_path, highlights_on: -> { controller_name == 'accounts' }
      more.item :tickets, 'Распродажа билетов', afisha_with_tickets_index_path, highlights_on: -> { controller_name == nil }
      more.item :news_of_tomsk, 'Новости Томска', 'http://news.znaigorod.ru'
      more.item :webcams, 'Веб-камеры', webcams_path, highlights_on: -> { controller_name == 'webcams' }
      more.item :contests, 'Конкурсы', contests_path, highlights_on: -> { %w[contests works].include? controller_name }
      more.item :services, 'Реклама', services_path, highlights_on: -> { controller_name == 'cooperation' }
      more.item :widgets, 'Виджеты', widgets_root_path, highlights_on: -> { controller_name.match(/widgets/i) }
      more.item :feedback, 'Отзывы и предложения', feedback_path, highlights_on: -> { controller_name == 'feedback' }
      more.item :questions, 'Спрашивай', questions_path, highlights_on: -> { controller_name == 'q'  }
      more.item :kurs_valut, 'Курсы валют', banki_tomsk_path, highlights_on: -> { controller_name == 'banki_tomsk'  }
    end
  end
end
