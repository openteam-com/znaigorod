@init_kinopoisk = ->

  trigger_kinopoisk_link = ->
    if movie_checkbox.is(':checked') && movie_title_field.val().length
      kinopoisk_links.slideDown()
    else
      kinopoisk_links.slideUp()
      $('ul', kinopoisk_links).remove()
    return

  form = $('form.simple_form')
  movie_checkbox = $('#afisha_kind_movie', form)
  movie_title_field = $('#afisha_title', form)
  kinopoisk_links = $('.kinopoisk_links', form)
  movies_from_kinopoisk_link = $('.movies_from_kinopoisk', kinopoisk_links)

  trigger_kinopoisk_link()

  movie_checkbox.change ->
    trigger_kinopoisk_link()
    return

  movie_title_field.keyup ->
    trigger_kinopoisk_link()
    return

  movies_from_kinopoisk_link.click ->
    link = $(this)
    return false if link.hasClass('busy')
    link.addClass('busy')
    $('ul', kinopoisk_links).remove()
    $.ajax
      url: link.attr('href')
      data: "title=#{movie_title_field.val()}"
      error: (jqXHR, textStatus, errorThrown) ->
        link.removeClass('busy')
        alert("Произошла ошибка загрузки списка фильмов")
        return
      success: (data, textStatus, jqXHR) ->
        link.removeClass('busy')
        kinopoisk_links.append(data)
        return
    return false

  $('ul.movies a', kinopoisk_links).live 'click', ->
    link = $(this)
    return true if link.hasClass('link_to_poster')
    return false if link.hasClass('busy')
    link.addClass('busy')
    $.ajax
      url: link.attr('href')
      error: (jqXHR, textStatus, errorThrown) ->
        link.removeClass('busy')
        alert("Произошла ошибка загрузки данных о фильме \"#{link.text()}\"")
        return
      success: (data, textStatus, jqXHR) ->
        link.removeClass('busy')
        if confirm('Данные с кинопоиска получены. Заменить?')
          $('#afisha_title', form).val(data.title)
          $('#afisha_original_title', form).val(data.original_title)
          $('#html', form).val(data.description)
          $('#afisha_tag', form).val(data.tags)
          $('#afisha_distribution_starts_on', form).val(data.premiere)
          $('#afisha_age_min', form).val(data.minimal_age)
          $('span', link.closest('li')).remove()
          link.closest('li').append(" <span>(<a class='link_to_poster' href='#{data.poster}' target='_blank'>ссылка на постер</a>)</span>")
          link.closest('li').append(" <span>(<a class='link_to_poster' href='#{data.url}' target='_blank'>просмотр на сайте</a>)</span>")
        return
    return false

  return
