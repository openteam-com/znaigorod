# -*- coding: utf-8 -*-

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    primary.item :adv_and_seo,           'Реклама и SEO', '#', :highlights_on => ->() { ['page_metas', 'banners', 'place_items'].include?(controller_name) } do |secondary|
      secondary.item :banners,           'Баннеры',               manage_banners_path
      secondary.item :brand,             'Бренд',                 manage_brands_path
      secondary.item :placed_banners,    'Размещаемые баннеры',   manage_placed_banners_path
      secondary.item :page_metas,        'Мета-описания страниц', manage_page_metas_path
      secondary.item :place_items,       'Продвигаемые элементы', manage_place_items_path
      secondary.item :promotions,        'Рекламные места',       manage_promotions_path
      secondary.item :main_page_reviews, 'Обзоры на главной',     manage_main_page_reviews_path
      secondary.item :main_page_posters, 'Афиши на главной',      manage_main_page_posters_path
      secondary.item :afisha_list_posters,   'Афиши на списочном виде',      manage_afisha_list_posters_index_path
      secondary.item :main_page_discounts,   'Скидки на главной',            manage_main_page_discounts_path
      secondary.item :discount_list_posters, 'Скидки на списочном виде',            manage_discount_list_posters_path
      secondary.item :teasers, 'Тизеры',      manage_teasers_path
    end

    primary.item :users, 'Пользователи', manage_admin_users_path,
      :highlights_on => ->(){ controller_name == 'users' || resource_class.try(:superclass) == User },
      :if => -> { can?(:manage, User) } do |users|
      users.item :accounts, 'Бейджи', manage_admin_accounts_path
    end

    primary.item :organisations, 'Заведения', manage_organizations_path,
      :highlights_on => ->(){ (controller_name == 'organizations' || resource_class.try(:superclass) == Organization) && namespace != 'crm'},
      :if => -> { can?(:manage, Organization) } do |org_item|
        Organization.available_suborganization_classes.each do |klass|
          org_item.item klass, klass.model_name.human, [:manage, klass.model_name.underscore.pluralize]
        end

        org_item.item :rated, 'Рейтинг организаций', manage_organizations_rated_path
        org_item.item :categories, 'Категории организаций', manage_organization_categories_path
        org_item.item :requests_to_published, 'Заявки на публикацию', requests_to_published_manage_organizations_path
        org_item.item :closed, 'Удалённые пользователем', closed_manage_organizations_path
        org_item.item :make_their_request, 'Заявки на присвоение', manage_make_their_organization_request_index_path
    end

    primary.item :afisha, 'Мероприятия', manage_afisha_index_path,
      :highlights_on => ->(){ controller_name == 'afisha' || controller_name == 'movie_fixers' },
      :if => -> { can?(:manage, [Afisha, MovieFixer]) } do |afisha_item|
        Afisha.kind.values.each do |kind|
          afisha_item.item kind, kind.text, by_kind_manage_afisha_index_path(kind.pluralize)
        end
        afisha_item.item 'draft', "Черновики (#{Afisha.draft.count})", by_state_manage_afisha_index_path(:draft)
    end

    primary.item :discounts, 'Скидки', manage_discounts_path,
      :highlights_on => ->(){ resource_class == Discount || resource_class == Coupon || resource_class == Certificate },
      :if => -> { can?(:manage, Discount) } do |discount_item|
        Discount.kind.values.each do |kind|
          discount_item.item kind, kind.text, by_kind_manage_discounts_path(kind.pluralize)
        end
        discount_item.item 'draft', "Черновики (#{Discount.draft.count})", by_state_manage_discounts_path(:draft)
      end

    primary.item :contests, 'Конкурсы', manage_contests_path,
      :highlights_on => ->(){ resource_class == Contest },
      :if => -> { can?(:manage, Contest) }

    primary.item :photogalleries, 'Фотопроекты', manage_photogalleries_path,
      :highlights_on => ->(){ resource_class == Photogallery },
      :if => -> { can?(:manage, Photogallery) }

    primary.item :reviews, 'Обзоры', manage_reviews_path,
      :highlights_on => ->(){ resource_class == Review },
      :if => -> { can?(:manage, Review) } do |review_item|
        Review.categories.options.each do |title, option|
          review_item.item option, title, by_category_manage_reviews_path(option)
        end
        review_item.item 'draft', "Черновики (#{Review.draft.count})", by_state_manage_reviews_path(:draft)
      end

    primary.item :payments, 'Вебкамеры', manage_webcams_path

    primary.item :crm, 'ЦРМ', crm_root_path,
      :highlights_on => ->(){ namespace == 'crm' },
      :if => -> { can?(:manage, :crm) } do |crm_item|
        [Organization, Activity].each do |kind|
          crm_item.item kind, kind.model_name.human, [:crm, kind.model_name.underscore.pluralize]
        end
        crm_item.item 'meetings', 'План встреч', [:meetings, :crm, :activities]
    end

    primary.item :statistics, 'Статистика' do |statistics_item|
      statistics_item.item :invitations, 'Сводка', manage_statistics_invitations_path
      statistics_item.item :payments, 'Платежи', manage_statistics_payments_path
      statistics_item.item :discount_with_prices, 'Купоны', manage_statistics_discounts_path
      statistics_item.item :sms_claims, 'Смс заявки', manage_statistics_sms_claims_path
      statistics_item.item :tickets, 'Билеты', manage_statistics_tickets_path
      statistics_item.item :tickets_2_0, 'Билеты 2.0', manage_statistics_ticket_statistic_path
      statistics_item.item :offers, 'Предложения цены', by_state_manage_statistics_offers_path(:fresh)
      statistics_item.item :comments, 'Комментарии', manage_comments_path, :if => -> { can?(:manage, Comment) }
      statistics_item.item :reviews, 'Обзоры', manage_statistics_reviews_path
      statistics_item.item :afishas, 'Афиши', manage_statistics_afishas_index_path
      statistics_item.item :discounts, 'Скидки', manage_statistics_discount_statistic_path
      statistics_item.item :links, 'Переходы по ссылкам', manage_statistics_links_path
    end

    primary.item :map_projects, 'Картопроекты', manage_map_projects_path,
      :highlights_on => ->() { controller_name == 'map_projects' || controller_name == 'map_layers'}

    primary.dom_class = 'navigation'
  end
end
