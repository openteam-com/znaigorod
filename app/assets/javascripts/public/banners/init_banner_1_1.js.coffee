@init_banner_1_1_shuffle = ->
  return if $('.js-banner li').length < 2

  $('.js-banner').shuffle()

  #setInterval ->
    #$('.js-banner li:nth-child(1)').fadeOut 'fast'
    #$('.js-banner li:nth-child(2)').fadeIn 'fast', ->
      #$('.js-banner').append($('.js-banner li:nth-child(1)'))
      #return

    #return
  #, 10000

  return
