@init_price_calculation = ->
  $('.tariffs').on 'change', ->
    $('#link_to_payment').attr('data-tariff', $(this)[0].id)
    link_generator()

  $('.filter_slider').on 'slidechange', (event, ui) ->
    $('#link_to_payment').attr('data-duration', ui.value)
    link_generator()

  link_generator = ->
    link = $('#link_to_payment')
    input_id = link.attr('data-tariff')
    tariff = $('#' + input_id)
    duration = link.attr('data-duration')
    slug = link.attr('data-slug')
    href_str = '/my/organizations/' + slug + '/tariff_organization_payments?duration=' + duration + '&' + 'tariff_id=' + tariff.attr('value')
    link.attr('href', href_str)
    price_calculating(duration, tariff)

  price_calculating = (duration, tariff) ->
    price_for_month = tariff.data().month
    price_for_sixmonths = tariff.data().sixmonths
    price_for_year = tariff.data().year
    price =
    if duration >= 1 && duration < 6
      price_for_month * duration
    else if duration == '6'
      price_for_sixmonths
    else if duration > 6 && duration < 12
      price_for_sixmonths + (duration - 6) * price_for_month
    else if duration == '12'
      price_for_year
    $('.calculated_price').html price
