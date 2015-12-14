module Yandex
  class Organization
    include Rails.application.routes.url_helpers

    attr_accessor :organization

    delegate :id, :title, :address, :email, :site, :logotype_url, :description,
      :to => :organization

    delegate :latitude, :longitude,
      :to => :address

    def initialize(organization)
      @organization = organization
    end

    def country
      'Россия'
    end

    def admn_area
      if Settings['app.city'] == 'tomsk'
        'Томская область'
      else
        'Севастопольская область'
      end
    end

    def locality_name
      if Settings['app.city'] == 'tomsk'
        'город Томск'
      else
        'город Севастополь'
      end
    end

    def info_page
      organization.subdomain? ?
        "http://#{organization.subdomain}.#{Settings['app.host']}" :
                                                     organization_url(organization, :host => Settings['app.host'])
    end

    def phones
      return [] unless organization.phone?

      organization.phone.split(',').map(&:squish)
        .map { |phone_number| phone_number.gsub(/[^\d]/, '') }
        .map { |phone_number| PhoneNumberNormalizer.new(phone_number).normalize }
    end

    def working_time
      grouped_schedules = organization.schedules.where(:holiday => false).inject([]) do |array, schedule|
        key = "#{I18n.l(schedule.from, :format => '%H:%M')}-#{I18n.l(schedule.to, :format => '%H:%M')}"

        key == array.last.try(:first) ? array.last.last << schedule : array << [key, [schedule]]

        array
      end

      return "ежедн. #{grouped_schedules.first.first}" if grouped_schedules.one? && grouped_schedules.flatten.size == 8

      array = grouped_schedules.map do |working_time, schedules|
        str = schedules.many? ?
          "#{schedules.first.short_human_day}-#{schedules.last.short_human_day} #{working_time}" :
          "#{schedules.first.short_human_day} #{working_time}"

          str.mb_chars.downcase.to_s
      end

      array.join(', ')
    end

    def rubrics
      @rubrics ||= companies.flat_map(&:rubrics)[0..2]
    end

    def actualization_date
      [suborganizations.map(&:updated_at), organization.updated_at].flatten.max.to_i
    end

    def images
      @images ||= companies.flat_map(&:images)
    end

    def features
      @features ||= companies.flat_map(&:features).inject({}) do |hash, attributes_list|
        attributes_list.each do |tag, features|
          hash[tag] ||= []

          hash[tag] += features
        end

        hash
      end
    end

    def companies
      @companies ||= suborganizations.map do |suborganization|
        company_class = "yandex/#{suborganization.class.name}".camelize.constantize

        company_class.new suborganization
      end
    end

    private

    def suborganizations
      @suborganizations ||= %w[meal sauna entertainment culture creation billiard sport]
        .map { |a| organization.send(a) }.compact
    end

    def build_company(suborganization)
      company_class = "yandex/#{suborganization.class.name}".camelize.constantize

      company_class.new suborganization
    end
  end
end
