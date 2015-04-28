/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

var vfs_path = $('#vfs_path').val();

if (vfs_path == undefined) {
  alert('Entry ID is undefined!\nCheck esp-ckeditor/config.js');
};

CKEDITOR.editorConfig = function( config )
{
  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  config.fillEmptyBlocks = false;

  config.disableNativeSpellChecker = false;

  config.baseFloatZIndex = 1000000;

  config.startupOutlineBlocks = true;

  /* Filebrowser routes */
  // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/el_finder/?vfs_path=" + vfs_path;

  // The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/el_finder/?vfs_path=" + vfs_path;

  // Rails CSRF token
  config.filebrowserParams = function(){
    var csrf_token = jQuery('meta[name=csrf-token]').attr('content'),
        csrf_param = jQuery('meta[name=csrf-param]').attr('content'),
        params = new Object();

    if (csrf_param !== undefined && csrf_token !== undefined) {
      params[csrf_param] = csrf_token;
    };

    params[vfs_path] = vfs_path;

    return params;
  };

  /* Toolbars */
  config.toolbar = 'Full';

  config.toolbar_Full = [
    ['Source'],
    ['Cut','Copy','Paste','PasteText','PasteFromWord'],
    ['Undo','Redo','-','Find','Replace','-','SelectAll'],
    ['Esp_link','Esp_unlink','Esp_anchor'],
    ['Esp_image', 'Esp_attachment', 'Esp_video', 'Esp_audio', 'Table'],
    '/',
    ['Format','Styles','Esp_Blockquote'],
    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','RemoveFormat'],
    ['JustifyLeft','JustifyCenter','JustifyRight'],
    ['NumberedList','BulletedList','-','Outdent','Indent'],
    ['SpecialChar'],
    ['Maximize', 'Esp_ShowBlocks']
  ];

  /* Format tags */
  config.format_tags = 'p;h1;h2;h3;div';

  /* Style tags */
  config.stylesSet = [
    { name: 'Cite',  element: 'cite' },
    { name: 'Mark',  element: 'mark' },
    { name: 'Далее', element: 'span', styles: { 'color': 'blue', 'border-bottom': '1px dashed blue' }, attributes: { class: 'js-opener-btn delimiter visible' } },
    { name: 'Цена',  element: 'span', styles: { 'color': 'brown' } }
  ];

};

CKEDITOR.on('instanceReady', function(ev) {

  ev.editor.dataProcessor.writer.indentationChars = "  ";

  var tags = new Array('h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'th', 'td', 'li', 'caption', 'th');
  for (var tag in tags) {
    ev.editor.dataProcessor.writer.setRules(tags[tag], {
      indent : false,
      breakBeforeOpen : false,
      breakAfterOpen : false,
      breakBeforeClose : false,
      breakAfterClose : true
    });
  };

  tags = ['div', 'blockquote', 'pre', 'audio','video'];

  for (var tag in tags) {
    ev.editor.dataProcessor.writer.setRules(tags[tag], {
      indent : true,
      breakBeforeOpen : true,
      breakAfterOpen : true,
      breakBeforeClose : true,
      breakAfterClose : true
    });
  };

  ev.editor.dataProcessor.writer.setRules('source', {
    indent : true,
    breakBeforeOpen : false,
    breakAfterOpen : true,
    breakBeforeClose : false,
    breakAfterClose : false
  });

  ev.editor.dataProcessor.htmlFilter.addRules({
    elements:
    {
      $: function (element) {
        // Output dimensions of images as width and height
        if (element.name == 'img') {
          var style = element.attributes.style;
          if (style) {
            // Get the width from the style.
            var match = /(?:^|\s)width\s*:\s*(\d+)px/i.exec(style),
                width = match && match[1];
            if (width) {
              element.attributes.style = element.attributes.style.replace(/(?:^|\s)width\s*:\s*(\d+)px;?/i, '');
              element.attributes.width = width;
            }
            // Get the height from the style.
            match = /(?:^|\s)height\s*:\s*(\d+)px/i.exec(style);
            var height = match && match[1];
            if (height) {
              element.attributes.style = element.attributes.style.replace(/(?:^|\s)height\s*:\s*(\d+)px;?/i, '');
              element.attributes.height = height;
            }
            // Get the float from the style.
            match = /(?:^|\s)float\s*:\s*([a-z]+);/i.exec(style);
            var float = match && match[1];
            if (float) {
              element.attributes.class = "float_" + float;
            }
          }
        }
        if (!element.attributes.style)
          delete element.attributes.style;
        return element;
      }
    }
  });

});
