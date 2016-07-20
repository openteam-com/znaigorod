class AddPromotionPlaceItemsForMainPage < ActiveRecord::Migration
  def up
    main_page_promo_id = Setting['app.city'] == 'sevastopol' ? 13 : 15
    Promotion.find(main_page_promo_id)
      .promotion_places.second
      .place_items
      .create(:url => '/main_page_afisha?content=afisha', :starts_at => DateTime.now, :ends_at => DateTime.now + 30.year, :title => 'Афиша мероприятий Томска')
    Promotion.find(main_page_promo_id)
      .promotion_places[2]
      .place_items
      .create(:url => '/main_page_photogalleries?content=photogalleries', :starts_at => DateTime.now, :ends_at => DateTime.now + 30.year, :title => 'Фотостримы Томска')
    Promotion.find(main_page_promo_id)
      .promotion_places[3]
      .place_items
      .create(:url => '/main_page_discounts?content=discounts', :starts_at => DateTime.now, :ends_at => DateTime.now + 30.year, :title => 'Скидки, сертификаты и купоны, акции и распродажи в Томске. Индивидуальный подбор.')
  end

  def down
  end
end
