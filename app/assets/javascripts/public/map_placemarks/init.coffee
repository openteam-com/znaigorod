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

    if $('.js-placemark_type').val() == 'manual'
      $('.js-placemark_type').val('relation')
      $(this).text('Добавить самостоятельно')
    else
      $('.js-placemark_type').val('manual')
      $(this).text('Или связать метку с...')

    false

   $(document).on 'ajax:success', '.new_map_placemark', (event, data, textStatus, jqXHR) ->
     $('.js-placemarks-list').slideUp('slow').html(data).slideDown('slow')

     true
