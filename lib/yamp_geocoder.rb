# encoding: utf-8

require 'curb'

class YampGeocoder
  def self.get_coordinates(options)
    options = {:city => "город #{Settings['app.city_ru']}"}.merge(options)
    region = "Томская область" if Settings['app.city'] == 'tomsk'
    address = [options[:city], region, options[:street], options[:house]].join(', ')
    address =  [options[:city], region, options[:address_string]].join(', ') if options[:address_string].present?
    parameters = { geocode: address, format: :json, results: 1 }
    result = [nil, nil]

    c = Curl::Easy.new("http://geocode-maps.yandex.ru/1.x/?#{parameters.to_query}") do |curl|
      curl.on_success do |easy|
        response = JSON.parse(easy.body_str)['response']['GeoObjectCollection']['featureMember'].first['GeoObject']
        result = response['Point']['pos'].split(' ')
        returned_house = response['name'].split(', ').last
        if returned_house.squish.eql?(options[:house].squish)
          result << '200'
        else
          result << '404'
        end
        result << response['name']
        result << response['description']
      end
    end

    begin
      c.perform if options[:street].present?
    rescue
      return { response_code: 500 }
    end

    Hash[[:longitude, :latitude, :response_code, :name, :description].zip(result)]
  end

  def self.get_houses(query)
    result = {}
    unless query.nil? || query.empty?
      cache = call_cache query
      if cache.nil?
        region = "Томская область" if Settings['app.city'] == 'tomsk'
        address = [Settings['app.city_ru'], region, query].join(', ')
        coords = [Settings['app.coords.longitude'], Settings['app.coords.latitude']].join(', ')
        parameters = {
          text: address,
          sll: coords,
          vrb: '1',
          perm: '1',
          source: 'houses',
          output: 'json'
        }
        address = ''
          c = Curl::Easy.new("http://maps.yandex.ru/?#{parameters.to_query}") do |curl|
            curl.on_success do |easy|
              result = JSON.parse(easy.body_str)
              result = result['vpage']['data']['locations']['GeoObjectCollection']['features'][0]['properties']['GeocoderMetaData']
              address = result['text']
              address = address.split(',')
              address.delete_at(0)
              address.delete_at(0)
              address = address.join(', ')
              if result['InternalToponymInfo']['houses'] != 0
                result = {
                  address: address,
                  houses: result['InternalToponymInfo']['Houses']
                }
              else
                geometry = result['InternalToponymInfo']['Point']
                name = result['AddressDetails']['Country']['AddressLine'].split(',').last()
                address =  result['AddressDetails']['Country']['AddressLine'].split(',')
                address.delete_at(0)
                address.delete_at(address.rindex(address.last))
                address = address.join(", ")
                result = {
                  address: address,
                  houses:[{
                    "name" => name,
                    "geometry" =>  geometry
                  }]
                }
              end

            end
          end
          begin
            c.perform if query.present?
          rescue
            return { response_code: 500 }
          end
        write_cache query, result
      else
        result = cache
      end
    end
    result
  end

  def self.call_cache key
    Rails.cache.read key
  end

  def self.write_cache key, obj
    Rails.cache.write key, obj, :expires_in => 1.day
  end

  def self.get_house_photo(coords)
    result = {}
    unless coords.empty?
      key = coords.gsub(',','').gsub('.','')
      cache = call_cache key
      if cache.nil?
        parameters = {
          lang: 'ru-RU',
          ll: coords,
          l: 'hph',
          results: '10',
          origin: 'maps-nav'
        }
        photos= []
        c = Curl::Easy.new("http://maps.yandex.ru/services/photos/1.x/photos.json?#{parameters.to_query}") do |curl|
          curl.on_success do |easy|
            result = JSON.parse(easy.body_str)
            result['entries'].each do |photo|
              photos.push photo['img']
            end
            result = photos
          end
        end
        begin
          c.perform if coords.present?
        rescue
          return { response_code: 500 }
        end
        write_cache key, result
      else
        result = cache
      end
    end
    result
  end

  def self.get_addresses(query)
    get_houses(query)
  end

  def geo_info_for(address, city = Settings['app.city_ru'])
    address_line = "#{city},#{address}"
    params = { :format => :json, :results => 1, :geocode => address_line }

    response = HTTParty.get("http://geocode-maps.yandex.ru/1.x/?#{params.to_query}")
    json = JSON.parse(response.body)
    geo_object = json['response']['GeoObjectCollection']['featureMember'].first['GeoObject']

    Hashie::Mash.new.tap do |hash|
      hash.address_line = geo_object['name']
      hash.longitude, hash.latitude = geo_object['Point']['pos'].split(' ')
    end
  end
end
