@init_banners_shuffle = ->
  return if $('.banner12 li').length < 2

  $('.banner12').shuffle()

  setInterval ->
    $('.banner12 li:nth-child(1)').fadeOut 'fast'
    $('.banner12 li:nth-child(2)').fadeIn 'fast', ->
      $('.banner12').append($('.banner12 li:nth-child(1)'))
      return

    return
  , 10000

  return
