@init_manipulate_contacts = () ->
  new_contact_link = $('.organization_show a.new_contact')
  new_contact_link.click (event) ->
    if $('.new_contact_form_wrapper', new_contact_link.closest('.right')).length
      $('.new_contact_form_wrapper form .actions .cancel', new_contact_link.closest('.right')).click()
      return  false
    $.ajax
      type: 'GET'
      url: new_contact_link.attr 'href'
      success: (data, textStatus, jqXHR) ->
        unless $('.new_contact_form_wrapper', new_contact_link.closest('.right')).length
          $('<div class=\'new_contact_form_wrapper\' />').insertAfter(new_contact_link.closest('h2'))
        new_contact_form_wrapper = $('.organization_show .new_contact_form_wrapper').hide()
        new_contact_form_wrapper.html(data)
        new_contact_form_wrapper.slideDown 'fast', ->
          $('form input:visible:first', new_contact_form_wrapper).focus()
          $('form #contact_phone', new_contact_form_wrapper).inputmask 'mask',
            'mask': '99-99-99'
          $('form #contact_mobile_phone', new_contact_form_wrapper).inputmask 'mask',
            'mask': '+7-(999)-999-9999'
          true
        true
    false

  $('.organization_show .new_contact_form_wrapper form').live 'submit', ->
    form = $(this)
    $.ajax
      type: 'POST',
      url: form.attr('action')
      data: form.serialize()
      success: (data, textStatus, jqXHR) ->
        if data.trim().startsWith('<div class=\'form_view\'>')
          form.closest('.new_contact_form_wrapper').html(data)
        if data.trim().startsWith('<ul class=\'contacts\'>')
          $('ul.contacts', form.closest('.right')).remove()
          form.closest('.right').append(data)
          $('.actions .cancel', form).click()
          $('ul.contacts li:first .name a', form.closest('.right')).click()
        true
    false

  $('.organization_show .new_contact_form_wrapper form .actions .cancel').live 'click', ->
    $('.organization_show .new_contact_form_wrapper').slideUp 'fast', ->
      $(this).remove()
      true
    false

  $('.organization_show .contacts .info .name a').live 'click', ->
    link = $(this)
    info = link.closest('.info')
    if $('.form_view', info).length && $('.details', info).is(':hidden')
      return false
    link.toggleClass('opened').toggleClass('closed')
    $('.details', link.closest('li')).slideToggle('fast')
    false

  $('.organization_show .contacts .info .edit a').live 'click', ->
    link = $(this)
    $.ajax
      type: 'GET'
      url: link.attr('href')
      success: (data, textStatus, jqXHR) ->
        details = link.closest('.details').slideUp('fast')
        link.closest('.info').append(data)
        form = $('.form_view', link.closest('.info')).hide()
        form.slideDown 'fast', ->
          $('input:visible:first', form).focus().select()
          $('#contact_phone', form).inputmask 'mask',
            'mask': '99-99-99'
          $('#contact_mobile_phone', form).inputmask 'mask',
            'mask': '+7-(999)-999-9999'
        true
    false

  $('.organization_show .contacts .info .form_view .actions .cancel').live 'click', ->
    $('.form_view', $(this).closest('.info')).slideUp 'fast', ->
      $(this).remove()
      true
    $('.details', $(this).closest('.info')).slideDown('fast')
    false

  $('.organization_show .contacts .info .form_view form').live 'submit', ->
    form = $(this)
    edit_url = $('.details .edit a', form.closest('.info')).attr('href')
    $.ajax
      type: 'POST',
      url: form.attr('action')
      data: form.serialize()
      success: (data, textStatus, jqXHR) ->
        if data.trim().startsWith('<div class=\'form_view\'>')
          info = form.closest('.info')
          $('.form_view', info).remove()
          info.append(data)
        if data.trim().startsWith('<ul class=\'contacts\'>')
          right_block = form.closest('.right')
          $('ul.contacts', right_block).remove()
          right_block.append(data)
          info = $(".contacts .info .details a[href='#{edit_url}']", right_block).closest('.info')
          $('.name a', info).click()
        true

    false

  $('.organization_show .contacts .info .form_view .actions .destroy').live 'ajax:success', (event, data, textStatus, jqXHR) ->
    right_block = $(this).closest('.right')
    $('ul.contacts', right_block).remove()
    right_block.append(data)
    true

  true

@init_manipulate_additional = () ->

  $('.organization_show .left .info .details .additional').each ->
    additional_block = $(this)
    $('.edit', additional_block).live 'click', ->
      additional_edit_link = $(this)
      $.ajax
        type: 'GET'
        url: additional_edit_link.attr('href')
        success: (data, textStatus, jqXHR) ->
          $('.view', additional_block).hide()
          additional_block.append(data)
          $('input:visible:first', additional_block).focus()
          $('#organization_phone_for_sms', additional_block).inputmask 'mask',
            'mask': '+7-(999)-999-9999'
            'showMaskOnHover': false
          init_datetime_picker()
          true
      false

    $('form .actions .cancel', additional_block).live 'click', ->
      $('.form_view', additional_block).remove()
      $('.view', additional_block).show()
      false

    $('form', additional_block).live 'submit', ->
      additional_edit_form = $(this)
      $.ajax
        type: 'POST'
        url: additional_edit_form.attr('action')
        data: additional_edit_form.serialize()
        success: (data, textStatus, jqXHR) ->
          $('.view', additional_block).remove()
          additional_edit_form.remove()
          additional_block.append(data)
          true
      false
    true
  true

@init_manipulate_activities = () ->
  activities_block = $('.organization_show .left .activities')

  activities_head_block = $('.activities_head', activities_block)

  $('.new_activity', activities_block).click ->
    link = $(this)
    if $('.form_view', activities_head_block).length
      $('.form_view form .cancel', activities_head_block).click()
      return false
    $.ajax
      type: 'GET'
      url: link.attr('href')
      success: (data, textStatus, jqXHR) ->
        wrapped = $("<div>#{data}</div>")
        $('h1', wrapped).remove()
        activities_head_block.append(wrapped.html())
        wrapped.remove()
        $('.form_view', activities_head_block).hide().slideDown('fast')
        init_datetime_picker()
        true
    false

  $('.form_view form .cancel', activities_head_block).live 'click', ->
    $('.form_view', activities_head_block).slideUp 'fast', ->
      $(this).remove()
      true
    false

  $('.form_view form', activities_head_block).live 'submit', ->
    form = $(this)
    $.ajax
      type: 'POST'
      url: form.attr('action')
      data: form.serialize()
      success: (data, textStatus, jqXHR) ->
        if data.isBlank()
          console.error 'Response is empty!' if console && console.error
          return false
        wrapped = $("<div>#{data}</div>")
        $('h1', wrapped).remove()
        data = wrapped.html().trim()
        if data.startsWith('<div class="form_view">')
          $('.form_view', activities_head_block).remove()
          activities_head_block.append(data)
          init_datetime_picker()
        if data.startsWith('<div class="activities_list">')
          $('.activities_list', activities_block).remove()
          activities_block.append(data)
          $('.form_view', activities_head_block).slideUp 'fast', ->
            $(this).remove()
            $('.activities_list', activities_block).effect 'highlight',
              color: '#ffb400'
            , 1000
        true
    false

  $('.form_view form .fast_activity', activities_head_block).live 'ajax:success', (event, data, textStatus, jqXHR) ->
    if data.isBlank()
      console.error 'Response is empty!' if console && console.error
      return false
    wrapped = $("<div>#{data}</div>")
    $('h1', wrapped).remove()
    data = wrapped.html().trim()
    if data.startsWith('<div class="form_view">')
      $('.form_view', activities_head_block).remove()
      activities_head_block.append(data)
      init_datetime_picker()
    if data.startsWith('<div class="activities_list">')
      $('.activities_list', activities_block).remove()
      activities_block.append(data)
      $('.form_view', activities_head_block).slideUp 'fast', ->
        $(this).remove()
        $('.activities_list', activities_block).effect 'highlight',
          color: '#ffb400'
        , 1000
    false

  $('.activities_list .edit a').live 'click', ->
    link = $(this)
    activities_list_block = link.closest('.activities_list')
    link_tr = link.closest('tr')
    if link_tr.next('tr').hasClass('edit_block')
      $('.form_view form .cancel', link_tr.next('tr')).click()
      return false
    $.ajax
      type: 'GET'
      url: link.attr('href')
      success: (data, textStatus, jqXHR) ->
        $('tr.edit_block .form_view', activities_list_block).slideUp 'fast', ->
          $(this).closest('tr.edit_block').remove()
          true
        $("<tr class='edit_block'><td colspan='#{$('td', link_tr).size()}'></td></tr>").insertAfter(link_tr)
        edit_block = $('tr.edit_block td', activities_list_block)
        wrapped = $("<div>#{data}</div>")
        $('h1', wrapped).remove()
        $('.form_view', wrapped).hide()
        data = wrapped.html().trim()
        edit_block.append(data)
        init_datetime_picker()
        $('.form_view', edit_block).slideDown('fast')
        true
    false

  $('.activities_list tr.edit_block .form_view form .cancel', activities_block).live 'click', ->
    $(this).closest('.form_view').slideUp 'fast', ->
      $(this).closest('tr.edit_block').remove()
      true
    false

  $('.activities_list tr.edit_block .form_view form', activities_block).live 'submit', ->
    form = $(this)
    edit_block = form.closest('tr.edit_block td')
    activities_list_block = form.closest('.activities_list')
    $.ajax
      type: 'POST'
      url: form.attr('action')
      data: form.serialize()
      success: (data, textStatus, jqXHR) ->
        wrapped = $("<div>#{data}</div>")
        $('h1', wrapped).remove()
        data = wrapped.html().trim()
        if data.startsWith('<div class="form_view">')
          edit_block.html(data)
          init_datetime_picker()
        if data.startsWith('<div class="activities_list">')
          activities_list_block.html($('.activities_list', wrapped).html())
          activities_list_block.effect 'highlight',
            color: '#ffb400'
          , 1000
        true
    false

  $('.activities_list tr.edit_block .form_view .actions .destroy').live 'ajax:success', (event, data, textStatus, jqXHR) ->
    wrapped = $("<div>#{data}</div>")
    $('h1', wrapped).remove()
    $(this).closest('.activities_list')
      .html($('.activities_list', wrapped).html())
      .effect 'highlight',
        color: '#ffb400'
      , 1000
    true

  true
