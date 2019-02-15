tinymce.PluginManager.add('placeholder', function(editor) {
  editor.on('init', function() {
    var label = new Label;

    onBlur();

    tinymce.DOM.bind(label.el, 'click', onFocus);
    editor.on('focus', onFocus);
    editor.on('blur', onBlur);
    editor.on('change', onChange);
    editor.on('setContent', onChange);

    function onFocus(){
      if(!editor.settings.readonly === true){
        if (editor.getContent() == "") {
          editor.setContent(label.placeholder);
        }
        label.hide();
      }
      editor.execCommand('mceFocus', false);
    }

    function onChange() {
      if(editor.getContent() == '') {
        label.show();
      } else{
        label.hide();
      }
    }

    function onBlur(){
      if(editor.getContent() == '') {
        label.show();
      } else if(editor.getContent() == "<p>" + label.placeholder + "</p>") {
        editor.setContent('');
        label.show();
      } else{
        label.hide();
      }
    }
  });

  var Label = function(){
    var placeholder_text = editor.getElement().getAttribute("placeholder") || editor.settings.placeholder;
    var placeholder_attrs = editor.settings.placeholder_attrs || {style: {position: 'absolute', top:'5px', left:'8px', color: '#888', padding: '1%', width:'98%', overflow: 'hidden', 'white-space': 'pre-wrap'} };
    var contentAreaContainer = editor.getContentAreaContainer();

    tinymce.DOM.setStyle(contentAreaContainer, 'position', 'relative');

    // Create label el
    this.el = tinymce.DOM.add( contentAreaContainer, "label", placeholder_attrs, placeholder_text );
    this.placeholder = placeholder_text;
  }

  Label.prototype.hide = function(){
    tinymce.DOM.setStyle( this.el, 'display', 'none' );
  }

  Label.prototype.show = function(){
    tinymce.DOM.setStyle( this.el, 'display', '' );
  }
});