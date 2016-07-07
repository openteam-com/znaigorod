@init_afisha_yandex_map = () ->

  ymaps.ready ->

    $map = $('.yandex_map .map')

    map = new ymaps.Map $map[0],
      center: [$map.attr('data-latitude'), $map.attr('data-longitude')]
      zoom: 15
      behaviors: []
    ,
      adjustZoomOnTypeChange: true

    map.cursors.push('pointer')

    map.events.add 'click', (event) ->
      init_modal_affiche_yandex_map($map)
      yaCounter14923525.reachGoal('affiche_map_click') if yaCounter14923525?
      true

    magnifier_layout = ymaps.templateLayoutFactory.createClass("<div class='magnifier_button'></div>")

    magnifier_button = new ymaps.control.Button
      data:
        title: 'Нажмите для увеличения карты'
    ,
      layout: magnifier_layout
      position:
        left: 5
        top: 5
      selectOnClick: false

    magnifier_button.events.add 'click', (event) ->
      yaCounter14923525.reachGoal('affiche_magnifier_click') if yaCounter14923525?
      init_modal_affiche_yandex_map($map)
      true

    map.controls.add(magnifier_button)

    affiche_placemark = new ymaps.GeoObject
      geometry:
        type: 'Point'
        coordinates: [$map.attr('data-latitude'), $map.attr('data-longitude')]
      properties:
        hintContent: $map.attr('data-hint')
    ,
      cursor: 'help'
      hasBalloon: false
      iconImageHref: '/assets/public/afisha_placemark.png'
      iconImageOffset: [-15, -40]
      iconImageSize: [37, 42]
      zIndex: 1000
      zIndexHover: 1100

    map.geoObjects.add(affiche_placemark)

    true

  true

@init_modal_affiche_yandex_map = (data_block) ->

  dialog_width = $(window).innerWidth() * 70 / 100
  dialog_height = $(window).innerHeight() * 90 /100

  ymaps.ready ->

    $('<div id=\'modal_affiche_yandex_map\'></div>').dialog
      title: data_block.attr('data-hint')
      width: dialog_width
      height: dialog_height
      modal: true
      resizable: false
      open: (event, ui) ->
        $map = $(this)

        $map.attr('data-latitude', data_block.attr('data-latitude'))
        $map.attr('data-longitude', data_block.attr('data-longitude'))
        $map.attr('data-hint', data_block.attr('data-hint'))
        $map.attr('data-id', data_block.attr('data-id'))

        map = new ymaps.Map this,
          center: [$map.attr('data-latitude'), $map.attr('data-longitude')]
          zoom: 16
          behaviors: ['drag', 'scrollZoom']
        ,
          adjustZoomOnTypeChange: true
          maxZoom: 23
          minZoom: 12

        affiche_placemark = new ymaps.GeoObject
          geometry:
            type: 'Point'
            coordinates: [$map.attr('data-latitude'), $map.attr('data-longitude')]
          properties:
            id: 'affiche_placemark'
            hintContent: $map.attr('data-hint')
        ,
          iconImageHref: '/assets/public/afisha_placemark.png'
          iconImageOffset: [-15, -40]
          iconImageSize: [37, 42]
          zIndex: 700

        if $map.attr('data-id')?
          affiche_placemark.events.add 'click', (event) ->
            return false if affiche_placemark.options.get('freeze')
            affiche_placemark.options.set('freeze', true)
            $.ajax
              method: 'GET'
              url: "/organizations/#{$map.attr('data-id')}/details_for_balloon"
              crossDomain: true
              success: (data, textStatus, jqXHR) ->
                item = data
                affiche_placemark.properties.set
                  balloonContentHeader: item.title
                  balloonContent: generate_item_description(item)
                affiche_placemark.options.set
                  hasBalloon: true
                affiche_placemark.balloon.open()
                true
            true
        else
          affiche_placemark.options.set
            cursor: 'help'
            hasBalloon: false

        map.geoObjects.add(affiche_placemark)

        map.controls.add 'zoomControl',
          top: 5
          left: 5

        render_organizations(map, $map.attr('data-id'))

        map.events.add 'actionend', (event) ->
          render_organizations(map, $map.attr('data-id'))
          true

        $('.organization_description .link a, .organization_description .image a').live 'click', (event) ->
          window.location.href = $(this).attr('href')
          false

        true

      close: (event, ui) ->
        $(this).dialog('destroy')
        $(this).remove()
        true

    true

  $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
    wrapped = $("<div>#{jqXHR.responseText}</div>")
    wrapped.find('title').remove()
    wrapped.find('style').remove()
    wrapped.find('head').remove()
    console.error wrapped.html().stripTags().unescapeHTML().trim() if console && console.error
    wrapped.remove()
    true

  true

render_organizations = (map, without_organization_id) ->

  a_x = map.getBounds()[0][0]
  a_y = map.getBounds()[0][1]
  b_x = map.getBounds()[1][0]
  b_y = map.getBounds()[1][1]

  link = "/organizations/in_bounding_box?location[ax]=#{a_x}&location[ay]=#{a_y}&location[bx]=#{b_x}&location[by]=#{b_y}"
  link += "&without=#{without_organization_id}" if without_organization_id?

  $.ajax
    type: 'GET'
    url: link
    crossDomain: true
    success: (data, textStatus, jqXHR) ->
      builded_placemarks = {}
      builded_placemark_ids = []
      freezed_placemarks = {}
      need_delete_placemarks = []

      $.each data, (index, item) ->
        builded_placemarks["id_#{item.id}"] = build_placemark(item)
        builded_placemark_ids.add "id_#{item.id}"
        true

      map.geoObjects.each (geoObject) ->
        return true if geoObject.properties.get('id').compact() == 'affiche_placemark'
        if builded_placemark_ids.indexOf(geoObject.properties.get('id')) != -1
          freezed_placemarks[geoObject.properties.get('id').compact()] = geoObject
        else
          need_delete_placemarks.add geoObject
        true

      $.each data, (index, item) ->
        return true if freezed_placemarks["id_#{item.id}"]
        map.geoObjects.add builded_placemarks["id_#{item.id}"]
        true

      $.each need_delete_placemarks, (index, item) ->
        map.geoObjects.remove item
        true

      true

  true

build_placemark = (item) ->

  switch item.category
    when 'aviatsionnye_kluby'
      icon = 'aviatsionnye_kluby'
    when 'antikafe', 'detskie_kafe', 'dostavka_edy', 'kafe', 'keytering', 'pitstserii', 'restorany', 'stolovye', 'sushi_bary', 'zavedeniya_bystrogo_pitaniya'
      icon = 'kafe'
    when 'attraktsiony', 'nochnye_kluby', 'razvlekatelnye_kompleksy', 'striptiz_bary', 'karaoke'
      icon = 'attraktsiony'
    when 'avtomoyki', 'legkovye_avtomobili'
      icon = 'avto'
    when 'banketnye_zaly', 'bary'
      icon = 'bary'
    when 'basseyny'
      icon = 'basseyny'
    when 'biblioteki'
      icon = 'biblioteki'
    when 'bilyardnye_zaly'
      icon = 'bilyard'
    when 'boevye_iskusstva'
      icon = 'boevye_iskusstva'
    when 'bouling'
      icon = 'bouling'
    when 'dvortsy_kultury', 'folklor', 'teatry', 'teatralnye_studii', 'literaturnye_studii', 'tsirkovye_studii', 'shkoly_animatorov'
      icon ='teatry'
    when 'gruzovye_i_spetstehnika'
      icon = 'gruzovye'
    when 'filarmonii', 'muzykalnye_studii'
      icon = 'filarmonii'
    when 'fitnes', 'fitnes_kluby', 'ozdorovitelnyy_tsentr', 'spa_salony', 'studii_zagara'
      icon = 'fitnes'
    when 'futbol', 'stadiony'
      icon = 'futbol'
    when 'ippodromy', 'konnye_kluby'
      icon = 'ippodromy'
    when 'gornolyzhnye_kompleksy'
      icon = 'lyzhy'
    when 'katki', 'ledovye_dvortsy', 'lyzhnye_bazy', 'zakalivanie'
      icon = 'snow'
    when 'massazhnye_salony', 'uslugi_massazhista'
      icon = 'massazh'
    when 'mototehnika'
      icon = 'mototehnika'
    when 'muzei'
      icon = 'muzei'
    when 'hudozhestvennaya_gimnastika', 'shkoly_tantsev', 'tantsevalnye_shkoly', 'tsentry_yogi', 'yoga'
      icon = 'yoga'
    when 'inostrannye_yazyki', 'korporativnye_predlozheniya_obrazovaniya', 'personalnye_predlozheniya_obrazovaniya', 'kluby_po_interesam'
      icon = 'inostrannye_yazyki'
    when 'parikmaherskie', 'nogtevye_studii', 'tatu_salony', 'velnes_zaly', 'vizazh_studii'
      icon = 'parikmaherskie'
    when 'peyntbol', 'sportivno_takticheskie_kluby', 'straykbol'
      icon = 'peyntbol'
    when 'igrovye_vidy_sporta', 'professionalnye_sportivnye_kluby', 'sportivnye_sektsii', 'sportivnye_shkoly'
      icon = 'sport'
    when 'izo_studii', 'konstruirovanie', 'masterilki', 'razvivayuschie_zanyatiya'
      icon = 'tvorchestvo'
    when 'sauny'
      icon = 'sauny'
    when 'shahmatnye_shkoly'
      icon = 'shahmaty'
    when 'trenazhyornye_zaly'
      icon = 'trenazhyory'
    when 'kinostudii', 'kinoteatry', 'fotoshkoly'
      icon = 'kino'
    when 'karting'
      icon = 'karting'
    when 'kofeyni', 'chaynaya', 'konditerskie'
      icon = 'kofeyni'
    when 'planetarii'
      icon = 'planetarii'
    when 'vodnyy_transport'
      icon = 'vodnyy_transport'
    else
      icon = 'default'

  point = new ymaps.GeoObject
    geometry:
      type: 'Point'
      coordinates: [item.latitude, item.longitude]
    properties:
      id: "id_#{item.id}"
      hintContent: item.title
  ,
    iconImageHref: "/assets/public/map_icons/#{icon}.png"
    iconImageOffset: [-15, -40]
    iconImageSize: [37, 42]
    hasBalloon: true

  point.events.add 'click', (event) ->
    return false if point.options.get('freeze')
    point.options.set('freeze', true)
    $.ajax
      method: 'GET'
      url: "/organizations/#{item.id}/details_for_balloon"
      crossDomain: true
      success: (data, textStatus, jqXHR) ->
        item = data
        point.properties.set
          balloonContentHeader: item.title
          balloonContent: generate_item_description(item)
        point.balloon.open()
        true
    true

  point

generate_item_description = (item) ->
  item_description = "" +
    "<div class='organization_description'>" +
    "<div class='image'>" +
    "<a href='#{item.url}'>" +
    "<img alt='#{item.title}' title='#{item.title}' src='#{item.logo.replace(/\/\d+-\d+\//, '/60-60!/')}' width='60' height='60' />" +
    "</a>" +
    "</div>" +
    "<div class='clearfix'>"
    "<p class='address'>#{item.address}</p>"
  item_description += item.phones if item.phones?
  item_description += item.schedule_today
  item_description += "" +
     "<p class='link'><a href='#{item.url}'>страница организации</a></p>" +
     "</div>"
     "</div>"

  item_description


@init_organization_map = () ->
  form = $('.edit_organization, .new_organization')
  $map = $('#map')
  map = $map.draw_organization_map()
  city_field = $('#organization_address_attributes_city')
  street_field = $('#organization_address_attributes_street')
  house_field = $('#organization_address_attributes_house')
  latitude_field = $('#organization_address_attributes_latitude')
  longitude_field = $('#organization_address_attributes_longitude')
  $('.get_coordinates', form).click ->
    return false if street_field.val() == '' || house_field.val() == ''
    $.ajax
      url: "/yamp_geocoder"
      async: false
      dataType: "json"
      data: "city=#{city_field.val()}&street=#{street_field.val()}&house=#{house_field.val()}"
      success:  (json, textStatus, jqXHR) ->
        if json.response_code == '500'
          alert "Cервис временно не доступен"
          return false
        latitude_field.val(json.latitude)
        longitude_field.val(json.longitude)
        map.setCenter [json.latitude, json.longitude]
        map.geoObjects.each (geoObject) ->
          if (geoObject.properties.get('id') == 'placemark')
            geoObject.geometry.setCoordinates [json.latitude, json.longitude]
          true
        if json.response_code == '404'
          alert "Координаты по указанному адресу не найдены!\nПожалуйста уточните адрес\nИли сохраняйте без указания координат"
        true
    false
  true

$.fn.draw_organization_map = () ->
  $map = $(this)
  latitude_field = $('#organization_address_attributes_latitude')
  longitude_field = $('#organization_address_attributes_longitude')
  latitude = latitude_field.val() || $('.map_coords').attr('data-latitude')
  longitude = longitude_field.val() || $('.map_coords').attr('data-longitude')

  map = new ymaps.Map $map[0],
    center: [latitude, longitude]
    zoom: 16
    behaviors: ['drag', 'scrollZoom']
  ,
    maxZoom: 23
    minZoom: 12

  map.controls.add 'zoomControl',
    top: 5
    left: 5

  placemark = new ymaps.GeoObject
    geometry:
      type: 'Point'
      coordinates: [latitude, longitude]
    properties:
      id: 'placemark'
  ,
    draggable: true
    iconImageHref: '/assets/public/afisha_placemark.png'
    iconImageOffset: [-15, -40]
    iconImageSize: [37, 42]

  map.geoObjects.add(placemark)

  placemark.events.add 'dragend', (event) ->
    coordinates = placemark.geometry.getCoordinates()
    latitude_field.val (coordinates[0] + '').substring(0, 9)
    longitude_field.val (coordinates[1] + '').substring(0, 9)
    true

  map.events.add 'click', (event) ->
    coordinates = event.get('coordPosition')
    latitude_field.val (coordinates[0] + '').substring(0, 9)
    longitude_field.val (coordinates[1] + '').substring(0, 9)
    map.geoObjects.each (geoObject) ->
      if (geoObject.properties.get('id') == 'placemark')
        geoObject.geometry.setCoordinates [coordinates[0], coordinates[1]]
      true
    true

  map
