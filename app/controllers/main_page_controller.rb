class MainPageController < ApplicationController
  respond_to :html, :promotion

  def show
    respond_to do |format|
      format.html {
        @organizations     = NewOrganizationsPresenter.new({})
        @accounts          = AccountsPresenter.new(:per_page => 6, :acts_as => ['inviter', 'invited'], :with_avatar => true)
        @webcams           = Webcam.our.published.shuffle.take(4)
        @decorated_reviews = MainPageReview.used.map { |m| ReviewDecorator.new m.review }
      }

      format.promotion {
        if params['content'] == 'afisha'
          @afisha_list              = MainPagePoster.where('afisha_id is not null').ordered.actual.map { |afisha| AfishaDecorator.new Afisha.find(afisha.afisha_id) }
          @afisha_excursions_list   = AfishaPresenter.new(:per_page => 6, :without_advertisement => true, :order_by => 'creation', :categories => ['excursions']).decorated_collection
          other_afishas_list        = AfishaPresenter.new(:per_page => 6 - @afisha_list.count, :without_advertisement => true, :order_by => 'creation', main_page: @afisha_list.any? ? true : false).decorated_collection
          @afisha_list              += other_afishas_list
          @afisha_filter            = AfishaPresenter.new(:has_tickets => false)
          render :partial => 'promotions/main_page_afisha'
        elsif params['content'] == 'photogalleries'
          @photogalleries    = Photogallery.order('id desc').limit(3)
          @photo_decorator   = PhotogalleryDecorator.decorate(@photogalleries)
          render :partial => 'promotions/main_page_photogalleries'
        elsif params['content'] == 'discounts'
          @discounts         = DiscountsPresenter.new(:type => 'coupon', :per_page => 5).decorated_collection
          advertisement      = Advertisement.new(list: 'main_page_discounts')
          advertisement.places_at(1).compact.each do |adv|
            @discounts[adv.position] = adv
          end
          @discount_filter   = DiscountsPresenter.new(params)
          render :partial => 'promotions/main_page_discounts'
        end
      }
    end
  end
end
