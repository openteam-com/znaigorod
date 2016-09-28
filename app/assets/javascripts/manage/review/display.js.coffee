@init_display_changes_table = ->
  $(".link_to_display_changes").on 'click', ->
    $(".changes").toggle()

@init_display_moderating = ->
  $(".link_to_display_moderating").on 'click', ->
    $(".decision").toggle()
