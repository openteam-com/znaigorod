@init_discount_map = () ->
  $.fn.get_coordinates_handler = () ->
    $this = $(this)

    address = $('.autosuggest').val()

    $.ajax "/geo_info?address=#{address}",
      type: "GET"
      dataType: "json"
      async: false
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'ERROR'
      success: (data, textStatus, jqXHR) ->
        $this.data('latitude', data.latitude)
        $this.data('longitude', data.longitude)

  $.fn.add_click_handler = () ->
    $this = $(this)
    $this.change_organization_id_handler()

    $this.click ->
      if $('.map_wrapper').length
        container = $('.map_wrapper')
      else
        container = $('<div class="map_wrapper" style="width:640px; height: 480px;" />').appendTo('body').hide()

      $this.get_coordinates_handler()

      latitude = $this.data('latitude')
      longitude = $this.data('longitude')

      map = null

      container.dialog
        draggable: false
        height: 480
        modal: true
        resizable: false
        title: 'Укажите координаты места проведения'
        width: 640
        zIndex: 700
        open: ->
          map = container.draw_affiche_map($this, latitude, longitude)
        close: ->
          $('.ymaps-map').remove()
      false

    true

  $.fn.draw_affiche_map = (link, latitude, longitude) ->
    $map = $(this)

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

    map.events.add 'click', (event) ->
      coordinates = event.get('coordPosition')
      $('.autosuggest_organization_id', $(link).parent()).val('').change()
      $('.autosuggest_organization_latitude', $(link).parent()).val(coordinates[0]).change()
      $('.autosuggest_organization_longitude', $(link).parent()).val(coordinates[1]).change()
      console.log $(link)

      $(link).data('latitude', coordinates[1])
      $(link).data('longitude', coordinates[2])

      $(link).addClass('with_coordinates')
      map.geoObjects.each (geoObject) ->
        if (geoObject.properties.get('id') == 'placemark')
          geoObject.geometry.setCoordinates [coordinates[0], coordinates[1]]
        true
      true

    placemark.events.add 'dragend', (event) ->
      coordinates = placemark.geometry.getCoordinates()
      $('.autosuggest_organization_id', $(link).parent()).val('').change()
      $('.autosuggest_organization_latitude', $(link).parent()).val(coordinates[0]).change()
      $('.autosuggest_organization_longitude', $(link).parent()).val(coordinates[1]).change()
      $(link).data('latitude', coordinates[1])
      $(link).data('longitude', coordinates[2])

      $(link).addClass('with_coordinates')
      true

    map

  $.fn.change_organization_id_handler = () ->
    label = $('.autosuggest', $(this).parent()).prev('label').css('width', 'auto')
    label_html = label.html().replace(' [связано с организацией. <a href="#">очистить</a>]', "")
    field = $('.autosuggest_organization_id', $(this).parent())
    if field.val().length
      label.html("#{label_html} [связано с организацией. <a href='#'>очистить</a>]")
      $('a', label).unbind('click').click ->
        field.val('').change()
        false
    $(field).change ->
      if field.val().length > 0
        label.html("#{label_html} [связано с организацией. <a href='#'>очистить</a>]")
        $('a', label).unbind('click').click ->
          field.val('').change()
          false
      else
        label.html("#{label_html}")
      true
    true

  link = $('.choose_coordinates')

  link.each ->
    $(this).add_click_handler()
    true
  true
