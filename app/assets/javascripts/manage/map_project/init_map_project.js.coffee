@init_map_project = () ->

  ymaps.ready ->
    $map = $('.map_project_wrapper .map_project_map')
    map = new ymaps.Map $map[0],
      center: [$map.attr('data-latitude'), $map.attr('data-longitude')]
      zoom: 11
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
      size: [35, 50]
      offset: [-18, -18]
    }]

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

    $('.map_project_wrapper .placemarks_list p').each (index, item) ->
      link = $('a', item)
      title = link[0].text

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


@init_map_placemark = () ->
  $.fn.add_click_handler = () ->
    $this = $(this)
    $this.click ->
      if $('.map_wrapper').length
        container = $('.map_wrapper')
      else
        container = $('<div class="map_wrapper" style="width:640px; height: 480px;" />').appendTo('body').hide()
      latitude = $('#map_placemark_latitude', $(this).parent())
      longitude = $('#map_placemark_longitude', $(this).parent())
      coordinates = { 'latitude': latitude.val(), 'longitude': longitude.val() }
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
          map = container.draw_map($this, coordinates)
        close: ->
          map.destroy()
      false

    true

  $.fn.draw_map = (link, coordinates) ->
    $map = $(this)
    latitude = coordinates.latitude || $('.map_coords').attr('data-latitude')
    longitude = coordinates.longitude || $('.map_coords').attr('data-longitude')
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
      $('#map_placemark_latitude', $(link).parent()).val(coordinates[0]).change()
      $('#map_placemark_longitude', $(link).parent()).val(coordinates[1]).change()
      $(link).addClass('with_coordinates')
      map.geoObjects.each (geoObject) ->
        if (geoObject.properties.get('id') == 'placemark')
          geoObject.geometry.setCoordinates [coordinates[0], coordinates[1]]
        true
      true

    placemark.events.add 'dragend', (event) ->
      coordinates = placemark.geometry.getCoordinates()
      $('#map_placemark_latitude', $(link).parent()).val(coordinates[0]).change()
      $('#map_placemark_longitude', $(link).parent()).val(coordinates[1]).change()
      $(link).addClass('with_coordinates')
      true

    map


  link = $('.choose_coordinates')

  link.each ->

    $(this).add_click_handler()
    true

  $('.toggle_forms').click ->
    $('.relations').toggle()
    $('.not_zg_object').toggle()
    if $('.js-placemark_type').val() == 'manual'
      $('.js-placemark_type').val('relation')
    else
      $('.js-placemark_type').val('manual')

    true

  init_tagit()

  $(document).on 'change', '.select_type', ->
    $('.tagit_categories').tagit('createTag', $(' option:selected', this).text())
    $(this).val($('option:first', this).val())

    true

init_tagit = ->
  console.log 'init'
  $('.tagit_categories').tagit
    fieldName:        'categories',
    allowDuplicates:  false,
    readOnly:         true,
    placeholderText:  ''
    beforeTagAdded: (event, ui) ->
      if ui.tagLabel == $('.select_type option:first').text()
        return false

    true

  true
