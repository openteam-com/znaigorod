@init_display_changes_table = ->
  alert("22222")
  $(".link_to_display").on 'click', ->
    $(".changes").toggle()
