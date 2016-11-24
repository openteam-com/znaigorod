@init_users_auto_complete = ->
  $('.js-input_user').on 'keydown', ->
    input_name = $(this)
    target_user_id = $('.target_user_id')
    target_email = $('.target_email')
    link_confirm_role = $('.js-confirm_role_link')
    input_name.autocomplete
      source: input_name.data('autocomplete-source')
      minLength: 2

      focus: (event, ui) ->
        $(this).val(ui.item.label)
        false

      select: (event, ui) ->
        organization_id = $('#js_organization_id')[0].value
        link_confirm_role.attr('href', '/my/organizations/' + organization_id + '/send_about_confirm_role?user_id=' + ui.item.value + '&user_email=' + ui.item.email)
        $(this).val(ui.item.label)
        target_user_id.val(ui.item.value)
        target_email.val(ui.item.email)
        false

  $(document).on 'keyup', '.target_email', ->
    input_email = $(this)
    input_id = $('.target_user_id')
    organization_id = $('#js_organization_id')[0].value
    link_confirm_role = $('.js-confirm_role_link')
    link_confirm_role.attr('href', '/my/organizations/' + organization_id + '/send_about_confirm_role?user_id=' + input_id[0].value + '&user_email=' + input_email[0].value)

  $('.js-confirm_role_link').on 'ajax:success', (e, data) ->
    $('ul.managers').replaceWith(data)
    $('.js-input_user').val('')
    $('.target_email').val('')
    $('.target_user_id').val('')

  $(document.body).on 'ajax:success', '.js-close_role_link', (e, data) ->
    $('ul.managers').replaceWith(data)

