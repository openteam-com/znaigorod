@init_users_auto_complete = ->
  $(document).on 'keydown', '.js-input_user', ->
    input_name = $(this)
    target = input_name.parent('.manager').find('.target_user_id')
    link_role = input_name.parent('.manager').find('.js-transfer_link')
    input_name.autocomplete
      source: input_name.data('autocomplete-source')
      minLength: 2

      focus: (event, ui) ->
        $(this).val(ui.item.label)
        false

      select: (event, ui) ->
        organization_id = link_role.data().organizationid
        user_id = ui.item.value
        link_role.attr('href', '/my/organizations/' + organization_id + '/transfer_main_role?user_id=' + user_id)
        $(this).val(ui.item.label)
        target.val(ui.item.value)
        false


