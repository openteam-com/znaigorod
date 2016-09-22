@init_display_changes_table = ->
  $(".link_to_display").on 'click', ->
    $(".changes").toggle()
