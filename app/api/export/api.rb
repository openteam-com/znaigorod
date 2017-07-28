module Export
  class API < Grape::API
    format :json
    prefix :export

    resources :afishas do

      desc 'Getting an actual afishas page'
      params do
        requires :offset, type: Integer
        requires :count, type: Integer
      end
      get '/' do
        Afisha.published.actual.with_showings.limit(params[:count]).offset(params[:offset]).map {|afisha|
          {
            remote_id: afisha.id,
            title: afisha.title,
            image_url: afisha.image_url,
            description: afisha.description,
            type: afisha.kind.to_a.first,
            original_title: afisha.original_title,
            trailer_code: afisha.trailer_code,
            tags: afisha.tag,
            age_min: afisha.age_min,
            vk_event_url: afisha.vk_event_url,
            schedules: afisha.showings.actual.where('starts_at < ? AND ends_at < ?', Date.current + 6.months, Date.current + 7.months)
            .select('latitude, longitude, place, price_min, price_max, starts_at, ends_at'),
            images: afisha.gallery_images.pluck(:file_url)
          }
        }
      end

    end
  end
end
