@init_set_reservation_balance_link = ->
  $('.js-reservation_balance_input').on 'change', ->
    link = $('.js-balance_payment_link')[0]
    slug = $(link).attr('data-slug')
    balance = $(this)[0].value
    href_str = '/my/organizations/' + slug + '/balance_reservation_organization_payments?amount=' + balance
    $(link).attr('href', href_str)
