@init_map_project = () ->

  ymaps.ready ->
    $map = $('.map_wrapper .map')
    map = new ymaps.Map $map[0],
      center: [$map.attr('data-latitude'), $map.attr('data-longitude')]
      zoom: 12
      behaviors: ['drag', 'scrollZoom']
      controls: []
    ,
      maxZoom: 23
      minZoom: 11

    map.controls.add 'fullscreenControl',
      float: 'none'
      position:
        top: 10
        left: 10

    map.controls.add 'geolocationControl',
      float: 'none'
      position:
        top: 50
        left: 10

    map.controls.add 'zoomControl',
      float: 'none'
      position:
        top: 90
        left: 10

    clusterIcons = [{
      href: $('.js-cluster-icon').attr('data-cluster_icon')
      size: [35, 50]
      offset: [-18, -18]
    }]

    create_new_placemark = (coords) ->
      map.geoObjects.removeAll()

      placemark = new ymaps.Placemark coords
      map.geoObjects.add placemark
      $('.js-ymaps-latitude').val(coords[0])
      $('.js-ymaps-longitude').val(coords[1])

      return

    if $('.map_placemark_form').length
     coords = [$('.js-ymaps-latitude').val(), $('.js-ymaps-longitude').val()]
     if coords && map.geoObjects.getLength() == 0
       create_new_placemark(coords)
       ymaps.geocode(coords).then (res) ->
         address = res.geoObjects.get(0)
         $('.js-ymaps-address').val(address.properties.get('name'))
         $('.js-ymaps-address').addClass('valid') unless $('.js-ymaps-address').hasClass('valid')

     map.events.add 'click', (e) ->
       coords = e.get('coords')
       create_new_placemark(coords)

       ymaps.geocode(coords).then (res) ->
         address = res.geoObjects.get(0)
         $('.js-ymaps-address').val(address.properties.get('name'))
         $('.js-ymaps-address').addClass('valid') unless $('.js-ymaps-address').hasClass('valid')

     $('.js-ymaps-direct-geocode').click ->
       ymaps.geocode("Томск, " + $('.js-ymaps-address').val(), results: 1).then (res) ->
         result = res.geoObjects.get(0)
         if result
           coords = result.geometry.getCoordinates()
           create_new_placemark(coords)
           $('.js-ymaps-address').addClass('valid') unless $('.js-ymaps-address').hasClass('valid')
           if $('.js-ymaps-address').val() == ''
              $('.js-ymaps-address').val('Центр Томска')

    clusterer = new ymaps.Clusterer
      clusterDisableClickZoom: true
      showInAlphabeticalOrder: true
      hideIconOnBalloonOpen: false
      groupByCoordinates: true
      clusterBalloonContentLayout: 'cluster#balloonCarousel'
      clusterBalloonPagerType: 'marker'
      clusterBalloonContentLayoutWidth: 192
      clusterBalloonContentLayoutHeight: 355
      clusterIcons: clusterIcons
      clusterIconContentLayout: null

    $('.map_projects_wrapper .placemarks_list p').each (index, item) ->
      link = $('a', item)
      title = link.text()

      img_width = 190
      img_height = 190
      schedule = ""
      if $(item).attr('data-type') == 'afisha'
        img_height = 260
        schedule = $(item).attr('data-when')

      point = new ymaps.GeoObject
        geometry:
          type: 'Point'
          coordinates: [$(item).attr('data-latitude'), $(item).attr('data-longitude')]
        properties:
          balloonContentBody: "" +
            "<div class='ymaps-2-1-17-b-cluster-content__body'>" +
            "<a href='#{link.attr('href')}' target='_blank'>" +
            "<img width='#{img_width}' height='#{img_height}' src='#{$(item).attr('data-image')}' />" +
            "</a>" +
            "<div class='balloon_content_header' style='border-bottom:1px dashed #ccc;margin:5px 0;padding-bottom:5px;width:190px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>" +
            "<a href='#{link.attr('href')}' target='_blank' title='#{title}'>#{title}</a>" +
            "</div>" +
            "<div style='margin-bottom: 5px;width:190px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>" +
            "<a href='#{$(item).attr('data-organization-url')}' target='_blank' title='#{$(item).attr('data-organization-title')}'>#{$(item).attr('data-organization-title')}</a>" +
            "</div>" +
            "<div>#{schedule}</div>"
          hintContent: title
      ,
        balloonMinWidth: 192
        balloonMaxWidth: 192
        hideIconOnBalloonOpen: false
        iconLayout: 'default#image'
        iconImageHref: $(item).attr('data-icon')
        iconImageSize: [35, 50]
        iconImageOffset: [-18, -18]

      clusterer.add point

      true

    map.geoObjects.options.set
      showHintOnHover: false

    map.geoObjects.add clusterer

    true

  true
