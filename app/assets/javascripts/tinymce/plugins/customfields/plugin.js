tinymce.PluginManager.add('customfields', function(editor, url) {
  // Add a button that opens a window
  function getValues() {
    return editor.settings.my_key_value_list;
  }

  editor.addButton('customfields', {
    title: 'Insert Field',
    icon: true,
    image: '/assets/insert_variable.png',
    onclick: function() {
      // Open window
      editor.windowManager.open({
        title: 'Custom Fields',
        body: [
          {
            type: 'listbox',
            name: 'Fields',
            onselect: function(e) {
              if (this.value() != 0) {
                editor.insertContent(' [' + this.value() + '] ');
                editor.windowManager.close();
              };
            },
            'values': getValues()
          }
        ]
      });
    }
  });

});