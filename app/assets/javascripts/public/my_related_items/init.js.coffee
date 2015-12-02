@loadRelatedAfishas = ->
  need_empty = false

  getRelatedItems = ->
    relatedItems=[]
    $('.hidden_ids').each ->
      relatedItems.push $(this).val()
    relatedItems

  getAjaxUrl = ->
    ajax_url = $('.type_select option:selected').val() || '/my/related_organizations'

  getSearchParam = ->
    searchParam = $('.related_search').val()

  just_one = ->
    return true if $('.js-just-one').length
    return false

  performAjax = ->
    $.ajax
      type: 'get'
      url: getAjaxUrl()
      data:
        related_items_ids: getRelatedItems()
        search_param: getSearchParam()
      success: (response) ->
        $('.posters:eq(0)').empty() if need_empty
        $('.posters:eq(0)').append(response)
        $('.posters:eq(0)').find('button').prop('disabled', true) if $('.element').length && just_one()
    false

  # on page load
  performAjax()

  $('.relations').on 'click', '.js-button-add-related-item', ->
    url = $(this).closest('.details').find('a')
    item_id = $(this).closest('.details').find('#hidden_id').val()
    params_name = $('.relations').find('.params_name').val()
    $(this).prop('disabled', true).text('Добавлено')
    $('.sticky_elements').append('<div class="element">
                                  <a href="' + url.attr('href') + '">' + url.text()  + '</a>
                                  <span class="del_icon"></span>
                                  <input name="'+params_name+'" type="hidden" value="' + item_id  + '" class="hidden_ids">
                                </div>')
    $('.posters:eq(0)').find('button').prop('disabled', true) if just_one()

    return

  $('.relations').on 'click', '.del_icon', ->
    $('input[value="'+$(this).parent().find('.hidden_ids').val()+'"]').closest('div').find('button').prop('disabled', false).text('Добавить')
    $(this).closest(".element").remove()

    $('.posters:eq(0)').find('button').prop('disabled', false) if just_one()

    return

  $('.type_select').change ->
    need_empty = true
    performAjax()

    true

  $('.sbm').click ->
    need_empty = true
    performAjax()

    true

  $('.related_search').keyup ->
    need_empty = true
    performAjax()

    true
