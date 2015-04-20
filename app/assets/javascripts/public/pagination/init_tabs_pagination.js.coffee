@window_scroll_init = (state) ->


  $('body .pagination').css
    'height': '0'
    'visibility': 'hidden'
  busy = false

  item = $("#discounts_filter ##{state} .discount_content .posters,
            #events_filter ##{state} .afisha_main_page_list .posters")
  first_item = $('li:first', item)
  return true unless first_item.length
  if first_item.siblings().length
    last_item = $('li:last', item)
  else
    last_item = first_item
  last_item_top = last_item.position().top

  last_item_offset = 400

  $(window).scroll ->

    if ($(this).scrollTop() + $(this).height()) >= (last_item_top - last_item_offset) && !busy
      busy = true
      a = $("##{state} .pagination a")
      url = a.attr('href')
      if url != undefined
        a.parent().remove()

        $.ajax
          url: url
          beforeSend: (jqXHR, settings) ->
            $('<li class="ajax_loading_items_indicator">&nbsp;</li>').appendTo(item)
            true
          complete: (jqXHR, textStatus) ->
            $('li.ajax_loading_items_indicator', item).remove()
            true
          success: (data, textStatus, jqXHR) ->
            return if  $(data).children().length == 1
            item.append(data)

            account_afisha_remove()

            $("##{state} .pagination").css
              'height': '0'
              'visibility': 'hidden'

            busy = false
            true

    true

