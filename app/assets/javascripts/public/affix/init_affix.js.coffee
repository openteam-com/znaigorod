@init_affix = () ->
  sidebar = $('.js-sidebar')
  navs = $('a', sidebar)

  sidebarOffset = 30
  sidebarTop = sidebar.offset().top

  sections = $('.js-scrolltrack')

  busy = false

  sections_positions = []
  sections.each (index, item) ->
    sections_positions.push($(this).offset().top - 30)

    return

  current_index = 0
  len = sections_positions.length
  getCurrent = (top) ->
    i = 0
    while i <= len
      if top > sections_positions[i] && top < sections_positions[i+1]
        return i
      i++

    return

  $(window).scroll ->
    scrollTop = $(this).scrollTop()
    windowTop = scrollTop + sidebarOffset

    if sidebarTop < windowTop
      sidebar.css
        'position': 'fixed'
        'top': "#{sidebarOffset}px"
    else
      sidebar.css
        'position': 'static'

    return if busy
    checkIndex = getCurrent(scrollTop)
    if checkIndex != currentIndex
      currentIndex = checkIndex
      navs.removeClass('active')
      current =  navs.eq(currentIndex)
      $('> a', current.parents('li')).addClass('active')

    return

  $('a', sidebar).click (e) ->
    href = $(this).attr('href')
    busy = true
    $.scrollTo href, 500,
      onAfter: ->
        window.location.replace href
        busy = false
        return
    $('.active', sidebar).removeClass('active')
    $('> a', $(this).parents('li')).addClass('active')

    return false

  if window.location.hash.length
    $('> a', $("a[href=#{window.location.hash}]").parents('li')).addClass('active')

  return

@init_fixed_menu = () ->
  sidebar = $('.js-fixed-menu')

  sidebarOffset = 10
  sidebarTop = sidebar.offset().top

  absolute = false

  $(window).scroll ->
    scrollTop = $(this).scrollTop()
    windowTop = scrollTop + sidebarOffset
    bottom = $(document).height() - $(sidebar).height() - $(sidebar).offset().top

    # TODO: need some fixes

    if sidebarTop < windowTop && bottom > 470
      sidebar.css
        'position': 'fixed'
        'top': "#{sidebarOffset}px"
      absolute = false
    else if bottom < 470 && windowTop > 5900
      return if absolute
      sidebar.css
        'position': 'absolute'
        'top': "#{$(sidebar).offset().top - $('.organization_show_navs').height()}px"
      absolute = true
    else
      sidebar.css
        'position': 'static'
      absolute = false

  $('.js_fixed_menu_item').click ->
    element = $(this).attr('href')
    $.scrollTo element, 750

    false
