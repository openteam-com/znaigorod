@init_light_crop = ->
  image = $('.js-light_crop')
  ratiow = image.data().ratiow
  ratioh = image.data().ratioh

  showCoords = (c) ->
    console.log c
    $('[id*="crop_x"]').val(c.x)
    $('[id*="crop_y"]').val(c.y)
    $('[id*="crop_width"]').val(c.w)
    $('[id*="crop_height"]').val(c.h)

  image.Jcrop
    aspectRatio: ratiow / ratioh
    onChange: showCoords
    allowSelect: false
    onSelect: showCoords
    setSelect: [0, 0, ratiow * 10, ratioh * 10]
