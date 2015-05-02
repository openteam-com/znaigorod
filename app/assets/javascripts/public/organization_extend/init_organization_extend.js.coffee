@init_organization_jump_to_afisha = ->
  $('.organization_show .afisha_details .presentation_filters .order_by a').click ->
    $.cookie('_znaigorod_jump_to_afisha', true)
    true

  if $.cookie('_znaigorod_jump_to_afisha')
    setTimeout ->
      $.scrollTo $('.organization_show .afisha_details'), 500, { offset: {top: -50} }
      $.removeCookie('_znaigorod_jump_to_afisha')
    , 500

  true

  $('.organization_show .discount_details .presentation_filters .order_by a').click ->
    $.cookie('_znaigorod_jump_to_discounts', true)

  if $.cookie('_znaigorod_jump_to_discounts')
    setTimeout ->
      $.scrollTo $('.organization_show .discount_details'), 500, { offset: {top: -50} }
      $.removeCookie('_znaigorod_jump_to_discounts')
    , 500

  true

@init_organization_site_link = ->
  $('.js-site-link').click ->
    target = $(this)
    $.ajax
      url: "/increment_site_link_counter"
      type: "GET"
      data:
        organization_id: $(target).attr('id')

      true
    true
  return

@init_organization_show_phone = ->
  $('body').on 'click', '.js-show-phone', ->
    target = $(this)
    $.ajax
      url: "/show_phone"
      type: "GET"
      data:
        organization_id: $(target).attr('id')
        single_phone: $(target).attr('single_phone')
      success: (response) ->
        $(target).parent().html(response)

      false
    false
  return

@init_organization_list_view_map = ->
  ymaps.ready ->
    $map = $('.suborganizations_map_wrapper .map')
    menu_width = if $('.tree').length then $('.tree').width() else $('.list_view_organization_list').width()
    map = new ymaps.Map $map[0],
      center: [$('.map_coords').attr('data-latitude'), $('.map_coords').attr('data-longitude')]
      zoom: 12
      behaviors: ['drag', 'scrollZoom']
      controls: []
    ,
      maxZoom: 23
      minZoom: 11

    map.controls.add 'zoomControl',
      float: 'none'
      position:
        top: 10
        left: menu_width + 20

    clusterer = new ymaps.Clusterer
      preset: 'islands#grayClusterIcons'
      clusterDisableClickZoom: true
      showInAlphabeticalOrder: true
      hideIconOnBalloonOpen: false
      groupByCoordinates: true
      clusterBalloonContentLayout: 'cluster#balloonCarousel'
      clusterBalloonPagerType: 'marker'
      clusterBalloonContentLayoutWidth: 210
      clusterBalloonContentLayoutHeight: 240


    $('.list_view_organization_item').each (index, item) ->
      link = $('.info h1 a', item)
      title = link.text()
      contentBody = if $(item).attr('data-status') == 'client'
                      "<div class='ymaps-2-1-17-b-cluster-content__body'>" + "<a href='#{link.attr('href')}' target='_blank'>" +
                      "<img width='190' height='190' src='#{$(item).attr('data-image')}' />" + "</a>" +
                      "<div class='balloon_content_header' style='margin:5px 0;padding-bottom:5px;width:190px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>" +
                      "<a href='#{link.attr('href')}' target='_blank' title='#{title}'>#{title}</a>" + "</div>"
                    else
                      "<div class='ymaps-2-1-17-b-cluster-content__body'>" +
                      "<a href='#{link.attr('href')}' target='_blank' title='#{title}'>#{title}</a>" + "</div>"

      point = new ymaps.GeoObject
        geometry:
          type: 'Point'
          coordinates: [$(item).attr('data-latitude'), $(item).attr('data-longitude')]
        properties:
          balloonContentBody: contentBody
          hintContent: title
          id: $(item).attr('data-slug')
      ,
        hideIconOnBalloonOpen: false
        iconLayout: 'default#image'
        iconImageHref: $(item).attr('data-icon')
        iconImageSize: [parseInt($(item).attr('data-width')), parseInt($(item).attr('data-height'))]
        iconImageOffset: [-18, -18]

      clusterer.add point

      true

    map.geoObjects.add clusterer

    $('.list_view_organization_posters').on 'ajax:success', '.pagination', (evt, response) ->
      $(response).filter('.list_view_organization_item').each (index, item) ->
        link = $('.info h1 a', item)
        title = link.text()
        point = new ymaps.GeoObject
          geometry:
            type: 'Point'
            coordinates: [$(item).attr('data-latitude'), $(item).attr('data-longitude')]
          properties:
            balloonContentBody: "" +
              "<div class='ymaps-2-1-17-b-cluster-content__body'>" +
              "<a href='#{link.attr('href')}' target='_blank' title='#{title}'>#{title}</a>" +
              "</div>"
            hintContent: title
            id: $(item).attr('data-slug')
        ,
          hideIconOnBalloonOpen: false
          balloonMinWidth: 210
          iconLayout: 'default#image'
          iconImageHref: $(item).attr('data-icon')
          iconImageSize: [parseInt($(item).attr('data-width')), parseInt($(item).attr('data-height'))]
          iconImageOffset: [-18, -18]

        clusterer.add point
      true

      map.geoObjects.add clusterer
      li_hover(clusterer)

      true

    $('.js-open-list').click ->
      $(this).parent().next('.categories').toggle()
      $(this).toggleClass('minus plus')
      false

    $('.js-swap-position').click ->
      $(this).parent().toggleClass('left_position right_position')
      $(this).parent().css('left','').css('right','10px')
      $(this).toggleClass('swap_left swap_right')
      $(this).parent().find('.js-resize').toggleClass('left right')
      $(this).parent().find('.js-breadcrumbs').toggleClass('left right')

      zoom_position = if $(this).is('.swap_left') then $(this).parent().width() + 20 else 1150 - $(this).parent().width()
      map.controls.remove 'zoomControl'
      map.controls.add 'zoomControl',
        float: 'none'
        position:
          top: 10
          left: zoom_position

      false

    li_hover(clusterer)

    $('.js-resizable').resizable({
      handles: "w, e"
      minWidth: 300
      maxWidth: 490
      minHeight: 598
      maxHeight: 628
      resize: (event, ui) ->
        target = ui.element
        target.css('height', 'auto')
        zoom_position = if $('.swap_left').length then ui.size.width + 20 else 1150 - ui.size.width
        map.controls.remove 'zoomControl'
        map.controls.add 'zoomControl',
          float: 'none'
          position:
            top: 10
            left: zoom_position

        if ui.size.width > 449
          target.addClass('maximum').removeClass('medium small')

        if ui.size.width <= 449 && ui.size.width > 365
          target.addClass('medium').removeClass('maximum small')

        if ui.size.width <= 365
          target.addClass('small').removeClass('medium')
    })
    true


  # state, h - highlight
  # state, n - not highlight
  init_hl_icons_on_map = (target, state = 'h', clusterer) ->
    objects = clusterer.getGeoObjects()
    objects.each (index, value) ->
      slug = index.properties.get('id')
      if $(target).attr('data-slug') == slug
        if state == 'n'
          index.options.set('iconImageHref', $(target).attr('data-icon'))
          index.options.set('zIndex', 100)
        else
          index.options.set('iconImageHref', $(target).attr('data-icon-hover'))
          index.options.set('zIndex', 1000)

    true

  li_hover = (clusterer) ->
    $('.js-organization-item').each (index, item) ->
      $(item).hover (e) ->
        init_hl_icons_on_map($(this), 'h', clusterer)
      , (e) ->
        init_hl_icons_on_map($(this), 'n', clusterer)

    true

@init_focus_for_search_button = () ->
  $('.js-search-field').focusin ->
    $('.js-search-button').toggleClass('selected')

  $('.js-search-field').focusout ->
    $('.js-search-button').toggleClass('selected')

@init_delimiter_on_sections = () ->
  $('.js-opener-btn').parent().nextAll().slideUp()

  $('.js-opener-btn').click ->
    $(this).parent().nextAll().slideDown()
    $(this).parent().find('js-closer-btn').slideDown()
    $(this).slideUp()

  $('.js-closer-btn').click ->
    $(this).slideUp()
    $.scrollTo "##{$(this).parent().parent().parent().attr('id')}", 500
    $(this).parent().find('.js-opener-btn').slideDown()
    $(this).parent().find('.js-opener-btn').parent().nextAll().slideUp()

  true
