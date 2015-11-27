@init_map_placemarks = ->
  $('.tagit_categories').tagit
    fieldName:        'categories',
    allowDuplicates:  false,
    readOnly:         true,
    placeholderText:  ''
    beforeTagAdded: (event, ui) ->
      if ui.tagLabel == $('.select_type option:first').text()
        return false

  $('.select_type').change ->
    $('.tagit_categories').tagit('createTag', $(' option:selected', this).text())
    $(this).val($('option:first', this).val())

  $('.js-switch-form').click ->
    $('.js-form-one').toggle()
    $('.js-form-two').toggle()
    false
