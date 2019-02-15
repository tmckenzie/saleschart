//= require jquery
//= require lib/remote_content
//= require plugins/snap.svg.js
//= require snap_thermometer

MC = {
  graphUrl: null,
  pollingTimeoutId: null,
  scrollingTimeoutId: null,
  maxHeight: null,
  typeName: null,
  pollingEnabled: true,
  init: function (graphUrl, percentEmpty, parent, name, noPolling) {
    var isInIframe = (parent !== window)

    if (isInIframe) {
      parent = document.referrer;
    }

    MC.parent = parent;
    if (parent)
      parent.iframeMC = MC;
    MC.pollingTimeoutId = null;
    MC.scrollingTimeoutId = null;
    MC.graphUrl = graphUrl;

    MC.percentEmpty = percentEmpty;
    MC.typeName = name;
    MC.initMercury();
    MC.updateMercury();
    MC.pollingEnabled = noPolling ? false : true

    if (graphUrl != "") {
      document.body.onclick = MC.requestFullScreen;
    }
    return MC;
  },
  requestFullScreen: function () {
    var el = document.documentElement;
    if (el.requestFullScreen) {
      el.requestFullScreen();
    } else if (el.mozRequestFullScreen) {
      el.mozRequestFullScreen();
    } else if (el.webkitRequestFullScreen) {
      el.webkitRequestFullScreen();
    }
  },
  cancelFullScreen: function () {
    var el = document.documentElement;
    if (el.cancelFullScreen)
      el.cancelFullScreen();
    else if (el.mozCancelFullScreen)
      el.mozCancelFullScreen();
    else if (el.webkitCancelFullScreen)
      el.webkitCancelFullScreen();
  },
  fullScreenElement: function () {
    return document.fullScreenElement || document.mozFullScreenElement || document.webkitFullScreenElement
  },
  fullScreenEnabled: function () {
    return document.fullScreenEnabled || document.mozScreenEnabled || document.webkitScreenEnabled
  },
  stop: function () {
    MC.stopPolling();
    MC.stopScrolling();
  },
  start: function () {
    MC.scrollAgain();
    if (MC.pollingEnabled) {
      MC.pollAgain();
    }
  },
  pollAgain: function () {
    MC.poll();
    MC.pollingTimeoutId = setTimeout(MC.pollAgain, 5000);
  },
  poll: function () {
    if (MC.graphUrl != null) {
      $.get(MC.graphUrl, function (data) {
        updateContent(null, data);
        MC.setEmptyHeight();
      });
    }
  },
  stopPolling: function () {
    clearTimeout(MC.pollingTimeoutId)
  },
  scrollAgain: function () {
    MC.scrollPledgeWall($('.pledgeWallPanel'), $('.pledgeWallCrop'));
    MC.scrollingTimeoutId = setTimeout(MC.scrollAgain, 30);
  },
  stopScrolling: function () {
    clearTimeout(MC.scrollingTimeoutId)
  },
  scrollPledgeWall: function ($pledgeWallPanel, $pledgeWallCrop) {
    if ($pledgeWallPanel.length > 0 && $pledgeWallCrop.length > 0) {
      var wallHeight = $pledgeWallPanel.height();
      var cropHeight = $pledgeWallCrop.height();
      if (wallHeight > cropHeight) {
        var top = $pledgeWallPanel.position().top;
        var newTop = top;
        if (Math.abs(top) <= wallHeight)
          newTop -= 2;
        else
          newTop = cropHeight;
        $pledgeWallPanel.css('top', newTop + 'px');
      }
    }
  },
  initMercury: function () {
    if (MC.typeName == 'books') {
      Thermometer.goal = 65;
      Thermometer.graphixMax = 521;
      Thermometer.raised = 50;
      Thermometer.update_callback = uCallback;
      Thermometer.empty = Snap(".graph #empty");
      Thermometer.calcByPercent = true;
      Thermometer.save();
    }
    else {
      MC.maxHeight = $('#empty').attr('height');
            var $settings = $('[data-content-key=mercury-settings]');
            $settings.on($settings.data('remote-signal'), MC.updateMercury);
    }

  },
  setEmptyHeight: function () {
    var emptyNum = $('[data-mercury-percent-empty]').data('mercury-percent-empty');
    if (MC.typeName == 'books') {
      Thermometer.percentComplete = 1 - emptyNum;

      Thermometer.update();

    }
    else {
      $('#empty').attr('height', Math.floor(MC.maxHeight * parseFloat(emptyNum)));
    }
  },
  setMercuryColor: function () {
    $('#mercury-color').attr('fill', $('[data-mercury-color]').data('mercury-color'));
  },
  updateMercury: function () {
    MC.setEmptyHeight();
    MC.setMercuryColor();
  }
};
