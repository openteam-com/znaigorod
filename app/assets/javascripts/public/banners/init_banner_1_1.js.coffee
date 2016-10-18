@init_banner_1_1_shuffle = ->
  return if $('.banner11 li').length < 2

  setInterval ->
    $('.banner11 li:nth-child(1)').fadeOut 'fast'
    $('.banner11 li:nth-child(2)').fadeIn 'fast', ->
      $('.banner11').append($('.banner11 li:nth-child(1)'))
      return

    return
  , 10000

  return
