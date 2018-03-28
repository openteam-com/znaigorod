@init_afisha_filter = () ->

  if $('.filters-by-wrapper .by_date .daily').is(':visible')
    link = $('.filters-by-wrapper .by_date .daily')
  else
    link = $('.filters_when_mobile .by_date .daily')

  wrapper = link.closest('li')

  create_obj_from_uri = ->
    params = {}
    uri = decodeURI(window.location.search.substr(1))
    return params unless uri.length
    pairs = uri.split('&').compact()
    for pair in pairs
      split = pair.split('=')
      params[decodeURIComponent(split[0])] = decodeURIComponent(split[1])

    params

  create_clear_button = (inst) ->
    return true unless wrapper.hasClass('selected')
    setTimeout (->
      buttonPane = $(inst).datepicker('widget').find('.ui-datepicker-buttonpane')
      btn = $("<button class='ui-datepicker-clear ui-state-default ui-priority-secondary ui-corner-all' type='button'>Очистить</button>")
      btn.appendTo buttonPane
      btn.unbind("click").bind "click", ->
        $.datepicker._clearDate inst.input
        object = create_obj_from_uri()
        object.period = 'all'
        delete object['on']
        search = $.param(object)
        if search.length
          window.location.replace(link.attr('href').replace(/\?.*/, '') + "?#{search}")
        else
          window.location.replace(link.attr('href').replace(/\?.*/, ''))
          window.location.reload()
        true
    ), 1

    true

  cal = $('<input id="ui-calendar" class="afishas-datepicker" type="text" />').appendTo('body').datepicker
    showButtonPanel: true
    dateFormat: 'yy-mm-dd'
    beforeShow: (input, inst) ->
      create_clear_button(inst)
      true
    onChangeMonthYear: (year, month, inst) ->
      create_clear_button(inst)
      true
    onSelect: (dateText, inst) ->
      link.text("#{inst.selectedDay} #{russian_monthes[inst.selectedMonth]}")
      wrapper.addClass('selected')
      year = inst.selectedYear
      month = if inst.selectedMonth + 1 < 10 then "0#{inst.selectedMonth + 1}" else inst.selectedMonth + 1
      day = if inst.selectedDay < 10 then "0#{inst.selectedDay}" else inst.selectedDay
      date = "#{year}-#{month}-#{day}"

      object = create_obj_from_uri()
      object.period = 'daily'
      object.on = date
      search = $.param(object)
      window.location.replace(link.attr('href').replace(/\?.*/, '') + "?#{search}")
      true

  object = create_obj_from_uri()
  if object.on
    cal.datepicker('setDate', object.on)
  else
    current_date = new Date
    cal.datepicker('setDate', current_date.toLocaleFormat('%Y-%m-%d'))

  set_calendar_position = ->
    cal.css
      'top': wrapper.offset().top
      'left': wrapper.offset().left
      'width': wrapper.outerWidth()
      'height': wrapper.outerHeight()

  set_calendar_position()

  $(window).resize ->
    set_calendar_position()

  link.click (event) ->
    if cal.datepicker('widget').is(':hidden')
      cal.datepicker('show')
    else
      cal.datepicker('hide')
    false

  true

@russian_monthes = [
  "января"
  "февраля"
  "марта"
  "апреля"
  "мая"
  "июня"
  "июля"
  "августа"
  "сентября"
  "октября"
  "ноября"
  "декабря"
]
