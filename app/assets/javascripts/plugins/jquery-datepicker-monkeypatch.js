/* Invoke the datepicker functionality.
   @param  options  string - a command, optionally followed by additional parameters or
                    Object - settings for attaching new datepicker functionality
   @return  jQuery object */
$.fn.datepicker = function(options){

    /* Verify an empty collection wasn't passed - Fixes #6976 */
    if ( !this.length ) {
        return this;
    }

    /* Initialise the date picker. */
    if (!$.datepicker.initialized) {
        $(document).mousedown($.datepicker._checkExternalClick).
            find('body .jquery_widget_wrapper').append($.datepicker.dpDiv); // added wrapper
        $.datepicker.initialized = true;
    }

    var otherArgs = Array.prototype.slice.call(arguments, 1);
    if (typeof options == 'string' && (options == 'isDisabled' || options == 'getDate' || options == 'widget'))
        return $.datepicker['_' + options + 'Datepicker'].
            apply($.datepicker, [this[0]].concat(otherArgs));
    if (options == 'option' && arguments.length == 2 && typeof arguments[1] == 'string')
        return $.datepicker['_' + options + 'Datepicker'].
            apply($.datepicker, [this[0]].concat(otherArgs));
    return this.each(function() {
        typeof options == 'string' ?
            $.datepicker['_' + options + 'Datepicker'].
                apply($.datepicker, [this].concat(otherArgs)) :
            $.datepicker._attachDatepicker(this, options);
    });
};