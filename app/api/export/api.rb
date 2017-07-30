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
        Afisha.with_showings.published
          .limit(params[:count]).offset(params[:offset]).map {|afisha|
          {
            remote_id: afisha.id,
            title: afisha.title,
            image_url: afisha.image_url,
            description: afisha.description,
            type: afisha.kind.to_a,
            original_title: afisha.original_title,
            trailer_code: afisha.trailer_code,
            tags: afisha.tag,
            constant: afisha.constant,
            age_min: afisha.age_min,
            vk_event_url: afisha.vk_event_url,
            showings: afisha.constant ? [] :
              afisha.showings.actual.where('starts_at < ?', Date.current + 6.months)
                .select('latitude, longitude, place, price_min, price_max, starts_at, ends_at'),
            schedule: !(afisha.constant && afisha.affiche_schedule.present?) ? nil :
              [
                :starts_on, :ends_on, :starts_at, :ends_at,
                :holidays, :place, :price_max, :price_min,
                :longitude, :latitude
              ].inject({}) {|hash, field| hash[field] = afisha.affiche_schedule.send(field); hash },
            images: afisha.gallery_images.pluck(:file_url)
          }
        }
      end

    end
  end
end
