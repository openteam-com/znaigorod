fresh_animation_handler = () ->
  $('.fresh').css('opacity', 1).removeClass('fresh').removeAttr('style')

next_page_handler = () ->
  button = $('.js-next-page')

  button.on 'ajax:beforeSend', (xhr, settings) ->
    return false if $(this).hasClass('disabled')

  button.on 'ajax:success', (evt, response) ->
    $('.pagination').remove()

    $('.js-paginable-list').addClass('paginable-list-paginated').append(response)

    init_sauna_halls_scroll() if $('.need_scrolling').length

    setTimeout (->
      fresh_animation_handler()
      return
    ), 250


@initButtonPagination = ->
  fresh_animation_handler()

  $('.js-next-page').live 'click', ->
    $(this).addClass('disabled').html('Загружаю...')

    next_page_handler()
