@init_geoip = ->

  $('.js-geoip').dialog
    autoOpen: true
    draggable: false
    modal: true
    position: ['center', 'center']
    resizable: false
    title: 'Укажите Ваше местоположение'
    width: '450px'
    open: (evt, ui) ->
      $('body').css('overflow', 'hidden')
    close: (event, ui) ->
      $('body').css('overflow', 'auto')
