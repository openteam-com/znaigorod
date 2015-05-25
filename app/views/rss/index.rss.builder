xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title "Все лучшее #{current_city_declension} от ЗнайГорода!"
    xml.description "Афиша, скидки и лучшие обзоры #{current_city_declension} - ЗнайГород"
    xml.link rss_url
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => rss_url(:format => :rss)

    for afisha in @afishas
      xml.item do
        xml.title afisha.title
        xml.enclosure :url => resized_image_url(afisha.poster_url, 200, 269), :type => 'image/jpeg',
          :length => begin open(URI.parse(resized_image_url(afisha.poster_url, 200, 269))).size; rescue; end
        xml.pubDate afisha.created_at.to_s(:rfc822)
        xml.guid afisha_show_url(afisha)
        xml.link afisha_show_url(afisha)
      end
    end

    for discount in @discounts
      xml.item do
        xml.title discount.title
        xml.enclosure :url => resized_image_url(discount.poster_url, 220, 164), :type => 'image/jpeg',
          :length => begin open(URI.parse(resized_image_url(discount.poster_url, 220, 164))).size; rescue; end
        xml.pubDate discount.created_at.to_s(:rfc822)
        xml.guid discount_url(discount)
        xml.link discount_url(discount)
      end
    end

    for review in @reviews
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
