@init_crop = () ->
  crop_x = parseInt($('[id*="crop_x"]').val()) || 0
  crop_y = parseInt($('[id*="crop_y"]').val()) || 0
  crop_width = parseInt($('[id*="crop_width"]').val()) || 0
  crop_height = parseInt($('[id*="crop_height"]').val()) || 0
  aspect_ratio = parseFloat($('[id*="aspect_ratio"]').val()) || 1
  min_width = parseFloat($('[id*="min_width"]').val()) || 0
  min_height = parseFloat($('[id*="min_height"]').val()) || 0

  $('.jcrop').Jcrop
    setSelect: [ crop_x, crop_y, crop_x + crop_width, crop_y + crop_height ]
    aspectRatio: aspect_ratio
    minSize: [min_width, min_height]
    onChange: (coords) ->
      update_crop(coords)
      crop_x = $('[id*="crop_x"]').val(coords.x)
      crop_y = $('[id*="crop_y"]').val(coords.y)
      crop_width = $('[id*="crop_width"]').val(coords.w)
      crop_height = $('[id*="crop_height"]').val(coords.h)
      true


  $('#afisha_poster_image').on 'change', ->
    $(this).parents('form').append('<input id="crop" name="crop" type="hidden" value="true">').submit()
    $(this).parents('form').submit()
    true

  true

  $('#discount_poster_image').on 'change', ->
    $(this).parents('form').append('<input id="crop" name="crop" type="hidden" value="true">').submit()
    $(this).parents('form').submit()
    true

  true

  $('#review_poster_image').on 'change', ->
    $(this).parents('form').append('<input id="crop" name="crop" type="hidden" value="true">').submit()
    $(this).parents('form').submit()

  $('#organization_logotype_url').on 'change', ->
    $(this).parents('form').append('<input id="crop" name="crop" type="hidden" value="true">').submit()
    $(this).parents('form').submit()
    true

update_crop = (coords) ->
  rx = 200/coords.w
  ry = 269/coords.h
  preview = $('.afisha_preview .poster img')

  preview.css
    width: Math.round(rx * preview.attr('width')) + 'px'
    height: Math.round(ry * preview.attr('height')) + 'px'
    marginLeft: '-' + Math.round(rx * coords.x) + 'px'
    marginTop: '-' + Math.round(ry * coords.y) + 'px'

  true
