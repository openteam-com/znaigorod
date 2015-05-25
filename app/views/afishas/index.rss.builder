xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Афиша #{current_city_declension} от ЗнайГород"
    xml.description "Афиша #{current_city_declension}, все мероприятия и афиша города #{current_city_declension} - ЗнайГород"
    xml.link afisha_index_url
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => afisha_index_url(:format => :rss)

    for afisha in @presenter.decorated_collection
      xml.item do
        xml.title afisha.title
        xml.enclosure :url => resized_image_url(afisha.poster_url, 200, 269), :type => 'image/jpeg',
          :length => begin open(URI.parse(resized_image_url(afisha.poster_url, 200, 269))).size; rescue; end
        xml.pubDate afisha.created_at.to_s(:rfc822)
        xml.guid afisha_show_url(afisha)
        xml.link afisha_show_url(afisha)
      end
    end
  end
end
