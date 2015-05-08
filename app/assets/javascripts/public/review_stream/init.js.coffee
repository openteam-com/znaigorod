@init_review_stream = ->

  #
  # Stream example: <div class='review_stream'>rtmp://example.com/application/video.mp4</div>
  #

  $('.review_stream').each (index, item) ->
    stream = $(item).text()
    container = $(item)
    container_id = "swfobject_container_#{index}"
    container.attr('id', container_id).wrap('<center></center>')
    width = 640
    height = 480

    swf_config =
      "swfUrl": "/assets/player.swf"
      "id": container_id
      "width": width.toNumber()
      "height": height.toNumber()
      "version": "9.0.115"
      "expressInstallSwfurl": "/assets/exp_inst.swf"
      "flashvars":
        "file": stream
        "vast_preroll": "/assets/vastconverter.xml"
        "vast_overlay": "/assets/vastconverter.xml"
        "st": "/assets/webcam.txt"
      "params":
        "bgcolor": "#ffffff"
        "allowFullScreen": "true"
        "allowScriptAccess": "always"
        "wmode": "opaque"
      "attributes":
        "id": container_id
        "name": container_id

    swfobject.embedSWF(
      swf_config.swfUrl,
      swf_config.id,
      swf_config.width,
      swf_config.height,
      swf_config.version,
      swf_config.expressInstallSwfurl,
      swf_config.flashvars,
      swf_config.params,
      swf_config.attributes
    )

    return

  return
