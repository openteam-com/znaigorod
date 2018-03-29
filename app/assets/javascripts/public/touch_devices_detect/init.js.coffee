@init_touch_devices_detect = ->
  elements = $('.js-need-touch-detect')

  if 'ontouchstart' of window
    elements.each ->
      element = this

      $(element).addClass('need-touch')
