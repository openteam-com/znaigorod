if Settings['app.city'] == 'tomsk'
  SitemapGenerator::Sitemap.default_host = Rails.env.production? ? "http://znaigorod.ru" : "http://localhost:3000"
else
  SitemapGenerator::Sitemap.default_host = Rails.env.production? ? "http://sevastopol.znaigorod.ru" : "http://localhost:3000"
end
SitemapGenerator::Sitemap.sitemaps_path = Rails.env.production? ? File.expand_path('../../../../shared/sitemaps/', __FILE__) : ''
SitemapGenerator::Sitemap.create_index = false

SitemapGenerator::Sitemap.create do
  def afisha_priority(afisha)
    return 1 - [(Date.today - afisha.created_at.to_date).days, 5].min * 0.1
  end

  def organization_priority(organization)
    organization.client? ? 1.0 : 0.5
  end

  # Список афиш
  add afisha_index_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Afisha.unscoped.last.updated_at
  add afisha_with_tickets_index_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Ticket.for_sale.last.afisha.updated_at if Ticket.any?

  # Список афиш по категориям
  Afisha.kind.values.each do |item|
    add send("#{item.pluralize}_path"),
      :changefreq => 'daily',
      :priority => 0.8,
      :lastmod => Afisha.actual.select{|a| a.kind.include?(item)}.last.updated_at
  end

  # Просмотр афиш
  Afisha.actual.each do |afisha|
    add send('afisha_show_path', afisha),
      :changefreq => 'weekly',
      :priority => afisha_priority(afisha),
      :lastmod => afisha.updated_at
  end

  # Список заведений
  add organizations_path, :changefreq => 'weekly', :priority => 1.0, :lastmod => Organization.unscoped.last.updated_at

  # Список заведений по категориям
  OrganizationCategory.roots.order(:position).each do |category|
    add organizations_by_category_path(category.slug), :changefreq => 'weekly', :priority => 0.8, :lastmod => category.updated_at
    category.children.order(:position).each do |child|
      add organizations_by_category_path(child.slug), :changefreq => 'weekly', :priority => 0.8, :lastmod => child.updated_at
    end
  end

  # Просмотр заведения
  Organization.find_each do |organization|
    add organization_path(organization),
      :changefreq => 'weekly',
      :priority => organization_priority(organization),
      :lastmod => organization.updated_at
  end

  # Список скидок
  add discounts_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Discount.unscoped.last.updated_at

  # Список скидок по категориям
  Discount.kind.values.each do |item|
    add send("discounts_#{item}_path"),
      :changefreq => 'daily',
      :priority => 0.8,
      :lastmod => Discount.actual.select { |a| a.kind.include?(item) }.last.try(:updated_at)
  end

  # Список веб-камер
  add webcams_path, :changefreq => 'weekly', :priority => 0.5, :lastmod => Webcam.published.unscoped.last.updated_at if Webcam.any?

  # Просмотр вер-камеры
  Webcam.published.each do |webcam|
    add webcam_path(webcam), :changefreq => 'weekly', :priority => '0.5', :lastmod => webcam.updated_at
  end

  # Конкурсы
  add contests_path, :changefreq => 'weekly', :priority => 0.5, :lastmod => Contest.unscoped.last.updated_at if Contest.any?

  # Фотогалереи
  add photogalleries_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Photogallery.unscoped.last.updated_at if Photogallery.any?

  # Знакомства
  add accounts_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Account.unscoped.last.updated_at

  # Знакомства по категориям
  Inviteables.instance.transliterated_category_titles.each do |transliterated, original|
    category = transliterated.dup

    add send("accounts_#{category}_path"),
      :changefreq => 'weekly',
      :priority => 0.5,
      :lastmod => Invitation.with_invited.where(:category => original).last.try(:updated_at)
  end

  # Список обзоров
  add reviews_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Review.unscoped.last.updated_at

  # Список обзоров по категориям
  Review.categories.values.each do |item|
    add send("reviews_#{item}_path"),
      :changefreq => 'daily',
      :priority => 0.8,
      :lastmod => Review.published.select { |p| p.categories.include?(item) }.last.try(:updated_at)
  end

  # Список вопросов
  add questions_path, :changefreq => 'daily', :priority => 1.0, :lastmod => Question.unscoped.last.updated_at if Question.any?

  # Список вопросов по категориям
  Question.categories.values.each do |item|
    add send("questions_#{item}_path"),
      :changefreq => 'daily',
      :priority => 0.8,
      :lastmod => Question.published.select { |p| p.categories.include?(item) }.last.try(:updated_at)
  end

  # Услуги и цены
  add services_path,      :changefreq => 'weekly', :priority => 0.5, :lastmod => DateTime.now - 7.days
  add benefit_path,       :changefreq => 'weekly', :priority => 0.5, :lastmod => DateTime.now - 7.days
  add statistics_path,    :changefreq => 'weekly', :priority => 0.5, :lastmod => DateTime.now - 7.days
  add our_customers_path, :changefreq => 'weekly', :priority => 0.5, :lastmod => DateTime.now - 7.days
  add ticket_sales_path,  :changefreq => 'weekly', :priority => 0.5, :lastmod => DateTime.now - 7.days
end
