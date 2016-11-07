@init_show_tipsy = () ->
  $('.show_tipsy').tipsy
    gravity: $.fn.tipsy.autoNS
    html: true
    live: true
    offset: 10
    opacity: 1

  true

  $('.show_tipsy_w').tipsy
    gravity: 'w'
    html: true
    opacity: 1
    offset: 10
