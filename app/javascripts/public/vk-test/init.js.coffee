@init_vk = ->
  load_widget = ->
    VK.Widgets.Group 'vk-group-lg',
      mode: 2
      width: '458'
      height: '633'
    , 145289764

    VK.Widgets.Group 'vk-group-md',
      mode: 2
      width: '294'
      height: '631'
    , 145289764

    return

  $(document).on "turbolinks:load", ->
    $('#vk-group-lg, #vk-group-md, #js-map').empty()

  $.getScript '//vk.com/js/api/openapi.js?113', ->
    load_widget()

