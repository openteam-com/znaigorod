@init_photogallery = () ->

  scroll_count = 3
  visible_count = 4
  start_position = if $('.js-start-position').length
    parseInt($('.js-start-position').text()) + 1
  else
    1

  if $('.photogallery').closest('.post_show, .gallery_wrapper').length
    scroll_count = 5
    visible_count = 6

  $('.photogallery ul').jcarousel
    scroll:   scroll_count
    visible:  visible_count
    start:    start_position

  $('.body .photogallery a').colorbox
    close: 'закрыть'
    current: '{current} из {total}'
    maxHeight: '90%'
    maxWidth: '90%'
    next: 'следующая'
    opacity: '0.5'
    photo: true
    previous: 'предыдущая'
    returnFocus: false
    title: ->
      $(this).attr('title') || $('img', this).attr('alt') || '&nbsp;'

  if $('.photogallery img').hasClass('stub')
    return true
  else
    $('.photogallery a').colorbox
      close: 'закрыть'
      current: '{current} из {total}'
      maxHeight: '90%'
      maxWidth: '90%'
      next: 'следующая'
      opacity: '0.5'
      photo: true
      previous: 'предыдущая'
      returnFocus: false
      title: ->
        $(this).attr('title') || $('img', this).attr('alt') || '&nbsp;'


  $('.js-section-colorbox a').colorbox
    close: 'закрыть'
    current: '{current} из {total}'
    maxHeight: '90%'
    maxWidth: '90%'
    next: 'следующая'
    opacity: '0.5'
    photo: true
    previous: 'предыдущая'
    returnFocus: false
    title: ->
      $('img', this).attr('title') || $('img', this).attr('alt') || '&nbsp;'

  true
