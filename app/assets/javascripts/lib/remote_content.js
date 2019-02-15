$(document).ready(function() {

    $("body").on("ajax:success", 'form[data-remote="true"], a[data-remote="true"]', function(event, data, status, xhr) {
        updateContent(event, data);
        $(document).trigger("mc-remote-content:success")
    });
    $("body").on("ajax:beforeSend", 'form[data-remote="true"], a[data-remote="true"]', function(event, data, status, xhr) {
        var target = $(this).find('.submit input[type=submit]');
        var original = target.val();
        target.val('processing');
        target.addClass('grey');
        target.attr('disabled', 'disabled').data('original_name', original)
    });
    $("body").on("ajax:complete", 'form[data-remote="true"], a[data-remote="true"]', function(event, data, status, xhr) {
        var target = $(this).find('.submit input[type=submit]');
        var name = target.data() ? target.data().original_name : '';
        if (name != undefined && name != '') {
            target.val(name);
        }
        target.removeAttr('disabled');
    });
    $("body").on("ajax:error", 'form[data-remote="true"], a[data-remote="true"]', function(event, data, status, xhr) {
        $(document).trigger("mc-remote-content:error", data.responseText)
    });
});

function updateContent(event, newContent) {
    var $contentKeyElements = $(newContent).filter('[data-content-key]');

    // iterate through each new content-key element
    var signals = [];
    var pushSignal = function ($match, $el) {
      var signal, targetSelector, $target;
      signal = $match.data('remote-signal');

      if (typeof signal === 'undefined' || (typeof signal === 'string' && signal.trim() === ''))
        return;
      targetSelector = $match.data('remote-signal-target');

      if (targetSelector === 'document')
        $target = $(document);
      else
        $target = $(targetSelector);

      if (! $target.length)
        $target = $match;
      signals.push(function () {$target.trigger(signal, [$el])});
    }

    $contentKeyElements.each(function() {
        var $el = $(this);
        var contentKey = $el.attr("data-content-key");

        // replace existing content-key html with new content-key html

        var matches = $("[data-content-key=" + contentKey + "]");
        if (matches.length < 1){
            var containerTarget = $el.attr('data-container-target');
            var $container = $("[data-container-key=" + containerTarget + "]");
            pushSignal($container, $el);
            if ($container.attr('data-prepend') == 'true')
              $container.prepend($el);
            else
              $container.append($el);
        } else {
            if ($el.html() !== matches.html()) {
              pushSignal(matches, $el);
              matches.html($el.html());
            }
        }
    });

    $.each(signals, function(i, fn) { fn() });
    $(document).trigger('content-updated');
}
