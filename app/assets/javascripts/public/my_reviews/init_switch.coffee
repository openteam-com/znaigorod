@init_switch = ->
  if $('.js-switch-wrapper').length
    if $('.js-switch').hasClass('active')
      $('.js-switch').find('input').prop('checked', true)

      true

  $('.js-switch-wrapper').on 'change', '.js-switch input', ->
    $.ajax
      url: "/my/reviews/#{$(this).parent().attr('id')}"
      type: 'put'
      data: {
        as_collage: $(this).prop('checked')
      }
      success: (data) ->
        $('.js-right-side-my-reviews').html(data)

    true
