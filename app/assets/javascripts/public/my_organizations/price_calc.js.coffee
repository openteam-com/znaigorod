@init_price_calculation = ->
  $('.js-slider_price').slider(
    max: 12
    min: 1
    step: 1
    value: 6)

  $('.js-slider_price').on 'slide', (event, ui) ->
    parent = $(this).parent('.payment')
    link = $(parent).find('.link_to_payment')

    slug = link.attr('data-slug')
    duration = ui.value
    tariff_id = $(link).attr('data-tariff-id')

    link.attr('href', '/my/organizations/' + slug + '/tariff_organization_payments?duration=' + duration + '&' + 'tariff_id=' + tariff_id)

    price = $(parent).find('.calculated_price')
    price_calculating(price, duration)

  price_calculating = (price, duration) ->
    price_for_month = price.data().month
    price_for_sixmonths = price.data().sixmonths
    price_for_year = price.data().year
    result_price =
    if duration >= 1 && duration < 6
      price_for_month * duration
    else if duration == 6
      price_for_sixmonths
    else if duration > 6 && duration < 12
      price_for_sixmonths + (duration - 6) * price_for_month
    else if duration == 12
      price_for_year
    price.find('.duration').html duration
    price.find('.result').html result_price

