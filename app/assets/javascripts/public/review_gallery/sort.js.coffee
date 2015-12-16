@handleReviewGallerySort = ->
  gallery = $('.js-gallery-sort')

  gallery.sortable
    revert: true

    stop: (event, ui) ->
      data = gallery.sortable 'serialize', attribute: 'data-id'

      $.post(gallery.data('sort-url'), data).done ->
        gallery.effect('highlight', {}, 1000)

        true
