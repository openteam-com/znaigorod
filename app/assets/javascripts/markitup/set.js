// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// Textile tags example
// http://en.wikipedia.org/wiki/Textile_(markup_language)
// http://www.textism.com/
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
mySettings = {
  previewParserPath: '',
  onShiftEnter: { keepDefault: false, replaceWith: '\n\n' },
  markupSet: [
    { name: 'Заголовок 2', key: '2', openWith: 'h2(!(([![Class]!]))!). ', placeHolder: 'Текст заголовка...', className: 'header_2_button' },
    { name: 'Заголовок 3', key: '3', openWith: 'h3(!(([![Class]!]))!). ', placeHolder: 'Текст заголовка...', className: 'header_3_button' },
    { separator: '-' },
    { name: 'Важно', key: 'B', closeWith: '*', openWith: '*', className: 'strong_button' },
    { name: 'Курсив', key: 'I', closeWith: '_', openWith: '_', className: 'italic_button' },
    { separator: '-' },
    { name: 'Ненумерованный список', openWith:'(!(* |!|*)!)', multiline: true, className: 'unordered_list_button' },
    { name: 'Нумерованный список', openWith:'(!(# |!|#)!)', multiline: true, className: 'ordered_list_button' },
    { separator: '-' },
    { name: 'Ссылка', openWith: '"', closeWith: '":[![Link:!:http://]!]', key: 'D', placeHolder: 'Текст ссылки...', className: 'link_button' },
    { name: 'Электронная почта', openWith: '"', closeWith: '":mailto:[![Email]!]', placeHolder: 'E-mail', className: 'email_button' },
    { name: 'Помощь', className: 'help_button',
      beforeInsert: function(h) {
        if (!$('.textile_syntax').length || !$.fn.dialog) {
          return true;
        }
        var textile_dialog_height = $(window).innerHeight() * 90 / 100;
        $('.js-textile_syntax').dialog({
          title: 'Синтаксис Textile',
          width: '1000',
          height: textile_dialog_height,
          modal: true,
          resizable: false,
          close: function() {
            $(this).parent().remove();
          }
        });
      }
    }
  ]
}
