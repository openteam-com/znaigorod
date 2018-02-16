@init_vk_group_widget = ->
  load_widget = ->
    VK.Widgets.Group 'vk-group',
      mode: 4
      no_cover: 0
      width: '1200'
      height: '620'
    , 35689602

    return

  $(document).on "turbolinks:load", ->
    $('#vk-group').empty()

  $.getScript '//vk.com/js/api/openapi.js?113', ->
    load_widget()
