@init_back_to_top = ->
  unless $('.back_to_top').length
    block = $('<div class=\'back_to_top\'><a href=\'#back_to_top\' title=\'Наверх\'>Наверх</a></div>')
    block.insertBefore('.footer_wrapper')
  else
    block = $('.back_to_top')

  $(window).scroll ->
    doc = document.documentElement
    body = document.body
    top = (doc && doc.scrollTop  || body && body.scrollTop  || 0)
    if top > window.innerHeight
      block.fadeIn()
    else
      block.fadeOut()

  $('a', block).click ->
    $('html, body').animate({ scrollTop: 0 }, "slow")
    false

  true
