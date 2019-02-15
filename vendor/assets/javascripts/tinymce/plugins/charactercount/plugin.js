tinymce.PluginManager.add('charactercount', function (editor) {
  var self = this;

  function update() {
    var item = editor.theme.panel.find('#charactercount');
    item.text(['Characters: {0}', self.getCharacterOnlyCount()]);

    //var errors = item[0].classes.cls.indexOf('error');
    //if ( (errors > 0) && (self.overLimit().indexOf('error') < 0)) {
    //  item[0].classes.cls.splice( errors, 1 );
    //} else if (self.overLimit().indexOf('error') > 0) {
    //  item[0].classes.cls.push('error');
    //}
  }

  editor.on('init', function () {
    var statusbar = editor.theme.panel && editor.theme.panel.find('#statusbar')[0];

    if (statusbar) {
      window.setTimeout(function () {
        statusbar.insert({
          type: 'label',
          name: 'charactercount',
          text: ['Characters: {0}', self.getCharacterOnlyCount()],
          classes: self.overLimit(),
          disabled: editor.settings.readonly
        }, 0);

        editor.on('setcontent beforeaddundo', update);

        editor.on('keyup', function (e) {
          update();
        });
      }, 0);
    }
  });

  self.getCharacterOnlyCount = function () {
    var tx = editor.getContent({ format: 'raw' });
    var decoded = decodeHtml(tx);
    var decodedStripped = decoded.replace(/(<([^>]+)>)/ig, "").trim();
    var tc = decodedStripped.length;
    return tc;
  };

  self.getCount = function () {
    var tx = editor.getContent({ format: 'raw' });
    var decoded = decodeHtml(tx);
    var tc = decoded.length;
    return tc;
  };

  function decodeHtml(html) {
    var txt = document.createElement("textarea");
    txt.innerHTML = html;
    return txt.value;
  }

  self.overLimit = function () {
    var limit = editor.getParam("limit");
    var currentCount = self.getCharacterOnlyCount();
    if (currentCount > limit) {
      return 'charactercount error';
    } else {
      return 'charactercount';
    }
  };

});