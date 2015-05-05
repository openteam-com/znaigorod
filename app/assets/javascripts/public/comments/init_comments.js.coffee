valid = (form) ->
  textarea = $('textarea', form).val()
  return false if textarea.length < 1 || /^\s*$/.test(textarea)
  true

add_uploaded_image = (image) ->
  uploaded_list = $('.uploaded_list', '.comments_images_wrapper')
  hidden_input = $("<input class='comments_image_#{image.id}' type='hidden' name='comment[comments_images_attributes][][id]' value='#{image.id}' data-preview='#{image.url}'>").appendTo(uploaded_list.closest('form'))
  uploaded_list
    .append("
      <div class='comments_image' id='comments_image_#{image.id}'>
        <img src='#{image.thumbnailUrl}' width='#{image.width}' height='#{image.height}' title='#{image.name}'>
        <a href='#{image.deleteUrl}' data-method='delete' data-remote='true' rel='nofollow' data-confirm='Вы точно хотите удалить эту картинку?'>Удалить</a>
      </div>
    ")
    .on 'ajax:success', (evt, response) ->
      comments_image = $(evt.target).closest('.comments_image')
      $('.'+comments_image.attr('id')).remove()
      comments_image.remove()
      false

init_comments_images = ->
  $('.comments_images_wrapper').fileupload
    acceptFileTypes:  /(\.|\/)(gif|jpe?g|png)$/i
    dataType:         'json'
    maxFileSize:      10000000
    url:              '/comments_images'
    done:             (evt, data) ->
      $('.ajax_blocking').hide()
      for file in  data.result.files
        add_uploaded_image file
    submit:           (evt, data) ->
      $('.ajax_blocking').show()
      uploaded_files_count = $('.uploaded_list .comments_image', '.comments_images_wrapper').length
      if (uploaded_files_count+data.originalFiles.length) > 5
        alert 'Слишком много картинок! Вы можете загрузить не больше 5 картинок!'
        throw 'Too many pics'
        false

@init_comments = () ->
  hash_answer = () ->
    $(window).load ->
      if window.location.hash.match(/#answer_/)
        if $("#comment_#{window.location.hash.match(/[0-9]+/)}").length
          $('a.new_answer', "#comment_#{window.location.hash.match(/[0-9]+/)}").click()
          $(document.body).scrollTo($("#comment_#{window.location.hash.match(/[0-9]+/)}"))

  hash_answer()

  cancel_handler = () ->
    $('.cancel', '.comments').on 'click', ->
      remove_comment_form()
      show_link()
      $('.comments .new_comment').click()
      false

  show_link = () ->
    $('.new_answer:hidden', '.comments').show()

  remove_comment_form = () ->
    remove_highlight()
    show_link()
    $('.ajaxed_item', '.comments').remove()

  scroll = () ->
    target = $('.ajaxed_item', '.comments')
    y_coord = Math.abs($(window).height() - target.offset().top - target.height()) + 150
    $("html, body").animate
      scrollTop: y_coord
    , ->
      $('textarea', target).focus()
      true

  remove_highlight = () ->
    $('.active', '.comments').removeClass('active')
    false

  $.fn.new_comment = (response) ->
    remove_comment_form()
    $(this).hide().siblings('ul').append(response)
    $(this).siblings('ul').trigger('added_form')

  $.fn.new_answer = (response) ->
    remove_comment_form()
    $(this).hide().closest('.comment_wrapper').addClass('active').siblings('ul').append(response)
    scroll()
    $(this).closest('.comment_item').trigger('added_form')

  $.fn.submit_form = (response) ->
    $(this).closest('.ajaxed_item').replaceWith(response)
    if !$(response).find('form').length
      remove_highlight()
      show_link()
      $('.comments .new_comment').click()

      # фотогалерея для новых комментариев с картинками
      init_photogallery() if $('.photogallery').length

  $(".ajaxed").on 'ajax:beforeSend', (evt, xhr, settings) ->
    $this = $(evt.target)
    if $this.is('a') && $this.hasClass('delete')
      $('.ajax_blocking').show()

    if $this.is('form') && $this.hasClass('new_comment')
      $('.ajax_blocking').show()
      unless valid($this)
        alert('Комментарий не может быть пустым')
        xhr.abort()
        $('.ajax_blocking').hide()
  .on "ajax:success", (evt, response, status, jqXHR) ->
    $('.ajax_blocking').hide()
    target = $(evt.target)
    if target.is('a') and target.hasClass('delete')
      target.closest('.comment_item').hide()

    if $('.social_signin_links', $(response)).length
      save_unauthorized_action(target)
      return false if $('body .sign_in_with').length
      $('.cloud_wrapper', target.closest('.social_actions')).remove()

      signin_container = $('<div class="sign_in_with" />').appendTo('body').hide().html(response)
      signin_container.dialog
        autoOpen: true
        draggable: false
        modal: true
        resizable: false
        title: 'Необходима авторизация'
        width: '500px'
        close: (event, ui) ->
          $(this).dialog('destroy')
          $(this).remove()
          true

      init_auth()

      return false

    switch target.attr('class')
      when 'new_comment' then target.new_comment(jqXHR.responseText)
      when 'new_answer'  then target.new_answer(jqXHR.responseText)
      else target.submit_form(jqXHR.responseText)

    cancel_handler()
    init_auth()
    init_comments_images()

  $('.comments .new_comment').click()
