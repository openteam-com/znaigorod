@init_map_placemarks = ->
  init_tagit()

  $(document).on 'change', '.select_type', ->
    $('.tagit_categories').tagit('createTag', $(' option:selected', this).text())
    $(this).val($('option:first', this).val())

    true

  $(document).on 'click', '.js-switch-form', ->
    $('.js-form-one').toggle()
    $('.js-form-two').toggle()

    if $('.js-placemark_type').val() == 'manual'
      $('.js-placemark_type').val('relation')
      $(this).text('Добавить самостоятельно')
    else
      $('.js-placemark_type').val('manual')
      $(this).text('Или связать метку с...')

    false

  $(document).on 'submit', '.new_map_placemark', ->
    $('.ajax_blocking').show()
    form = $(this)
    formData = new FormData(this)
    $.ajax
      type: 'POST',
      url: form.attr('action')
      data: formData
      contentType: false
      cache: false
      processData: false
      success: (data, textStatus, jqXHR) ->
        $('.ajax_blocking').hide()
        $('.js-map_placemark_form').slideUp('slow').html(data).slideDown('slow')
        init_tagit()
        loadRelatedAfishas()
        init_map_project()
        true
    false

init_tagit = ->
  console.log 'init'
  $('.tagit_categories').tagit
    fieldName:        'categories',
    allowDuplicates:  false,
    readOnly:         true,
    placeholderText:  ''
    beforeTagAdded: (event, ui) ->
      if ui.tagLabel == $('.select_type option:first').text()
        return false

    true
