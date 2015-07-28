@init_resize_google_ads_footer = ->
  frame = $('.js-google-ads-footer').find('iframe:eq(0)')
  if $(frame).attr('width') == 'undefined'
    #console.log 'main width is undefined, try to setup width'
    $(frame).attr('width', '980px')

    if $(frame).contents().find('iframe:eq(0)').attr('width') == 'undefined' || $(frame).contents().find('iframe:eq(1)').attr('width') == 'undefined'
      #console.log 'sub width is undefined, try to setup width'
      $(frame).contents().find('iframe:eq(0)').attr('width', '980px')
      $(frame).contents().find('iframe:eq(1)').attr('width', '980px')

      true
    true
  true

@init_resize_google_ads_right = ->
  frame = $('.js-google-ads-right').find('iframe:eq(0)')
  if $(frame).attr('height') == 'undefined'
    #console.log 'main width is undefined, try to setup height'
    $(frame).attr('height', '400px')

    if $(frame).contents().find('iframe:eq(1)').attr('height') == 'undefined'
      #console.log 'sub width is undefined, try to setup height'
      $(frame).contents().find('iframe:eq(1)').attr('height', '400px')

      true
    true
  true
