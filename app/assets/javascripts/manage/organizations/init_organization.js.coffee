@init_organization = () ->
  $('.new_section_link').click ->
    $('.new_section').toggle()
    false

  $('.new_section_button').click ->
    $.ajax
      type: "GET"
      data:
        section_title: $('#new_section').val()
      success: (response) ->
        $('.sections ul').append(response)
        $('.new_section').toggle()
        $('#new_section').val('')


  wrapper_sections = $('.sections_wrapper .js-sortable')
  wrapper_section_pages = $('.section_show .js-sortable')
  wrapper_gallery_images = $('.images .js-sortable')
  wrapper_navigations = $('.navigation_wrapper .js-sortable')

  init_sort(wrapper_sections)
  init_sort(wrapper_section_pages)
  init_sort(wrapper_gallery_images)
  init_sort(wrapper_navigations)

recalculate_position = (wrapper) ->
  $('li input.position', wrapper).each (index, item) ->
    $(item).val index+1
    true
  true

init_sort = (wrapper) ->
  $(wrapper).sortable
    axis: 'y'
    containment: 'parent'
    handle: '.sortable_handle'
    items: 'li'
    update: (event, ui) ->
      recalculate_position(ui.target)
      if wrapper.data('sort')
        $.ajax
          url: wrapper.data('sort')
          type: 'POST'
          data: wrapper.serialize()
          error: (jqXHR, textStatus, errorThrown) ->
            response = $("<div>#{jqXHR.responseText}</div>")
            $('meta', response).remove()
            $('title', response).remove()
            $('style', response).remove()
            console.error response.html().trim() if console && console.error
            true
          success: (data, textStatus, jqXHR) ->
            wrapper.effect 'highlight', 1500
            true
  true

@init_organization_form = () ->
  # при инициализации скрипта пометить корни согласно правилам
  $('.js-root').each (index, item) ->
    root = $(item).parent()
    children_checkboxes = $(root).next('.children').find('input')
    checked = 0
    children_checkboxes.each (index, item) ->
      if $(item).is(':checked')
        checked += 1

    check_root(root, checked, children_checkboxes.length)

  $('.js-open-list').click ->
    $(this).parent().parent().next('.children').toggleClass('opened closed')
    false

  $('.js-root').change ->
    root = $(this)[0]
    children = $(this).parent().next('.children').find('input')

    children.each (index, item) ->
      item.checked = root.checked
      true

    false

  $('input[type="checkbox"]').change ->
    root_class = $(this).parent().parent().attr('class').split(' ')

    return if root_class.indexOf('children') < 0

    root_class = $.grep(root_class, (val) ->
      val != 'children'
    )
    root_class = $.grep(root_class, (val) ->
      val != 'opened'
    )
    root_class = $.grep(root_class, (val) ->
      val != 'closed'
    )

    root = $(this).parent().parent().parent().find('.root_'+root_class[0])
    children_checkboxes = $(root).next('.children').find('input')

    checked = 0

    children_checkboxes.each (index, item) ->
      if $(item).is(':checked')
        checked += 1

    check_root(root, checked, children_checkboxes.length)

    true
  true

check_root = (root, checked, checkbox_count) ->
  if checked == checkbox_count
    root.find('input').prop('indeterminate', false) # indeterminate check for root
    root.find('input').prop('checked', true)
  else if checked == 0
    root.find('input').prop('indeterminate', false) # indeterminate check for root
    root.find('input').prop('checked', false)
  else
    root.find('input').prop('checked', false)
    root.find('input').prop('indeterminate', true) # indeterminate check for root

@initMarkitup = ->
  $('.markitup').markItUp(markItUpSettings())
  handleImageButtonClick()

markItUpSettings = ->
  settings = clone(mySettings)

  imageButton = {
    name:'Изображение'
    className: 'image_button'
    openWith: ''
    beforeInsert: (h) ->
      beforeImageInsert(h)
  }

  youtubeButton = {
    name: 'Видео с Youtube'
    className: 'youtube_button'
    replaceWith: '[![Добавление видео с Youtube:!:Просто вставьте сюда ссылку на видео с Youtube, например, http://www.youtube.com/watch?v=e-GYrbecb88]!]'
  }

  vimeoButton = {
    name: 'Видео с Vimeo'
    className: 'vimeo_button'
    replaceWith: '[![Добавление видео с Vimeo:!:Просто вставьте сюда ссылку на видео с Vimeo, например, http://vimeo.com/11192521]!]'
  }

  buyButton = {
    name: 'Добавить ссылку "Купить"'
    className: 'buy_button'
    replaceWith: "<div align='center' class='buy_button'> <a class='button payment_link' href='http://znaigorod.ru/discounts/#{get_discount_slug().responseText}/copy_payments/new'>[![Текст кнопки:!:Введите текст кнопки]!] </a> </div>"
  }

  delimiterButton = {
    name: 'Разделитель текста'
    className: 'delimiter_button'
    replaceWith: "<span class='js-opener-btn delimiter visible'>[![Текст разделителя:!:Введите текст разделителя]!]</span>"
  }

  settings.markupSet.push(imageButton)
  settings.markupSet.push(youtubeButton)
  settings.markupSet.push(vimeoButton)
  settings.markupSet.push(buyButton) if $('.discounts').length && $('form.simple_form').attr('class').indexOf('edit') > -1
  settings.markupSet.push(delimiterButton) if $('.js-is-section-page').length

  settings

get_discount_slug = ->
  $.ajax
    type: 'get'
    async: false

@handleImageButtonClick = ->
  $('.image_button').click ->
    $('#gallery_image_file').focus().trigger('click')

beforeImageInsert = (h) ->
  textarea = $(h.textarea)

  before = textarea.val()[0...h.caretPosition]
  after = textarea.val()[(h.caretPosition + h.selection.length)...textarea.val().length]

  file_input = $('.upload_gallery_images #gallery_image_file')

  file_input.fileupload
    dataType: 'json'

    done: (e, data) ->
      url = data.result.files[0].url
      textarea.val("#{before}!#{url}!#{after}")
      textarea.trigger('preview')

    start: (e) ->
      top = $(document).scrollTop()
      $('body').addClass('non_scrollable')

      $('.loader').show().offset
        left: 0
        top: top

    stop: (e) ->
      $('body').removeClass('non_scrollable')
      $('.loader').hide()

    fail: (e, data) ->
      message = data.jqXHR.responseText
      $('.message_wrapper').text(message).show().delay(5000).slideUp('slow')
