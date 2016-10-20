@init_full_schedules = ->
  $(document).on 'change', '.full_schedules_fields .fields .days .checkbox .boolean', ->
    if $(this)[0].checked == true
      day_name = $(this).attr('class').split(' ')[2]
      $('.full_schedules_fields .fields .days .checkbox .' + day_name).attr('checked', false)
      $(this).attr('checked', true)

  $('.full_schedules_fields').on 'DOMNodeInserted', '.fields', ->
    if $(this).find('.days').length == 1
      added_fields = $(this)
      l = $('.full_schedules_fields > .fields').length
      if l > 1
        all_fields = $('.full_schedules_fields > .fields')
        for i in [0..(l-2)]
          fields = $(all_fields[i])
          checks = fields.find('.days .checkbox .boolean')
          for j in [0..7]
            if $(checks[j])[0].checked == true
              day_name = $(checks[j]).attr('class').split(' ')[2]
              added_fields.find('.days .checkbox .' + day_name).attr('checked', false)


