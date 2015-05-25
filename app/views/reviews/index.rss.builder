xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Обзоры и блоги о жизни в #{current_city_inclination}"
    xml.description "Обзоры и блоги о жизни в #{current_city_inclination}"
    xml.link reviews_url
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => reviews_url(:format => :rss)

    for review in @presenter.decorated_collection
      xml.item do
        xml.title review.title
        xml.enclosure :url => review.annotation_image(200, 354), :type => 'image/jpeg',
          :length => begin open(URI.parse(review.annotation_image(200, 354))).size; rescue; end
        xml.pubDate review.created_at.to_s(:rfc822)
        xml.guid review_url(review)
        xml.link review_url(review)
      end
    end
  end
end
