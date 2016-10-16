@init_users_auto_complete = ->
  $(document).on 'keyup', '.js-input_user', ->
    input_name = $(this)
    target = input_name.parent('.manager').find('.target_user_id')
    target_email = input_name.parent('.manager').find('.target_email')
    link_main_role = input_name.parent('.manager').find('.js-transfer_link')
    link_confirm_role = input_name.parent('.manager').find('.js-confirm_role_link')
    input_name.autocomplete
      source: input_name.data('autocomplete-source')
      minLength: 2

      focus: (event, ui) ->
        $(this).val(ui.item.label)
        false

      select: (event, ui) ->
        organization_id = $('#js_organization_id')[0].value
        user_id = ui.item.value
        link_main_role.attr('href', '/my/organizations/' + organization_id + '/transfer_main_role?user_id=' + user_id)
        link_confirm_role.attr('href', '/my/organizations/' + organization_id + '/send_about_confirm_role?user_id=' + user_id + '&user_email=' + ui.item.email)
        $(this).val(ui.item.label)
        target.val(ui.item.value)
        target_email.val(ui.item.email)
        false

  $(document).on 'keyup', '.target_email', ->
    input_email = $(this)
    input_id = input_email.parents('.manager').find('.target_user_id')
    organization_id = $('#js_organization_id')[0].value
    link_confirm_role = input_email.parents('.manager').find('.js-confirm_role_link')
    link_confirm_role.attr('href', '/my/organizations/' + organization_id + '/send_about_confirm_role?user_id=' + input_id[0].value + '&user_email=' + input_email[0].value)
