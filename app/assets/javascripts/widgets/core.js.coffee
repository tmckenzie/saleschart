#= require modularized/placeholder-shiv
#= require jquery.blockUI
(($) ->
  class WidgetModel
    constructor: (options) ->
      @options = options
      for own k,v of @options
        @options[k] = Boolean(Number(v)) if /^(display_|include_styles)/.test(k)
    set: (options) ->
      $.extend(@options, options)
      $(@).trigger('mc:updated')
    get: (key) ->
      value = @options[key]
      if $.isFunction(value) then value() else value
    getKeys: ->
      key for own key, value of @options
    is_slimline: ->
      @options.layout is 'slimline'
    observer: (fn) ->
      $(@).on('mc:updated', fn)

  class WidgetView
    constructor: (model, $template) ->
      @model = model
      @$template = $template
      $(@model).on('mc:updated', => @render())
      @render()
    $: (selector) ->
      @$template.find(selector)
    render: ->
      @renderClasses()
      @renderAttributes()
      @renderToggles()
    renderClasses: ->
      @$('[data-mc-classes]').each (i, el) =>
        $el = $(el)
        optionSets = $el.data('mc-classes').split(',')
        fieldSets = $el.data('mc-class').split(',')
        $.each(optionSets, (i, options) =>
          field = fieldSets[i]
          $el.removeClass(options).addClass("mc-#{@model.get field}")
        )
    renderAttributes: ->
      @$('[data-mc-attr]').each (i, el) =>
        $el = $(el)
        attr = $el.data('mc-attr')
        field = $el.data('mc-model')
        if attr == 'html'
          $el.html(@model.get field)
        else
          $el.attr(attr, @model.get field)
    renderToggles: ->
      @$('[data-mc-toggle]').each (i, el) =>
        $el = $(el)
        field = $el.data('mc-toggle')
        toggle = @model.get field
        if toggle then $el.show() else $el.hide()
    block: ->
      $el = if @model.is_slimline() then @$dialog.find('[data-mc-block]') else @$('[data-mc-block]')
      $el.block({message: null, overlayCSS: {'border-radius':'15px'}})
    unblock: ->
      $el = if @model.is_slimline() then @$dialog.find('[data-mc-block]') else @$('[data-mc-block]')
      $el.unblock()
    bindFormHandler: ->
      $response = @$('[data-mc-response]')
      @$('[data-mc-widget-id-field]').val(@model.get('id'))
      if @model.is_slimline()
        # tried putting these two handlers inside initializeSlimlineDialog.  They work here, and break in there.  No idea why.
        @$('[data-mc-form]').on('submit', (e) =>
          e.preventDefault()
          @$dialog.dialog('open') if @validate($(e.target))
        )
        @$('[data-mc-trigger-submission-button]').on('click', (e) =>
          e.preventDefault()
          $form = @$('[data-mc-layout=slimline] [data-mc-form]')
          @block()
          $.getJSON(@model.get('form_action'), $form.serialize() + "&callback=?").success((data) =>
            @unblock()
            if data.error
              $response.addClass('mc-error').html(data.message).slideDown(500)
            else
              $response.removeClass('mc-error').html(data.message)
              $form[0].reset()
              @$dialog.dialog('close');
          )
        )
        @initializeSlimlineDialog()
      else
        @$('[data-mc-form]').on('submit', (e) =>
          e.preventDefault()
          $form = $(e.target)
          if @validate($form)
            @block()
            $.getJSON(@model.get('form_action'), $form.serialize() + "&callback=?").success((data) =>
              @unblock()
              if data.error
                $response.addClass('mc-error').html(data.message).fadeIn(500)
              else
                $response.removeClass('mc-error').html(data.message)
                $response.fadeTo(0,100).delay(2000).fadeTo(1000, 0)
                $form[0].reset()
            )
          return
        )
    initializeSlimlineDialog: ->
      @$dialog = $('[data-mc-dialog]', @$template)
      $('[data-mc-layout]', @$dialog).append($('[data-mc-dialog-body]', @$template).detach())
      @$dialog.find('[data-mc-layout]').data('mc-layout', 'slimline')
      @$dialog.find('[data-mc-cancel-submission-button]').on('click', (e) =>
        e.preventDefault()
        @$dialog.dialog('close')
        false
      )
      @$dialog.dialog(
        modal:true
        autoOpen:false
        dialogClass:"mc-mobilecause-widget mc-pledging-widget mc-dialog mc-#{@model.get('format_width')}"
        resizable:false
        width:'265px'
      )
      @$dialog.closest('.mc-dialog').addClass("mc-#{@model.get('background_color')}")
    disableForm: ->
      $form = @$('[data-mc-pledge-form]')
      $form.on('submit', (e) -> false)
      $form.find('input,select,textarea').each (i, el) -> $(el).attr('disabled','disabled')
    validate: (form)->
      valid = true
      $('[data-mc-validate]:visible', form).each (i, el) ->
        $el = $(el)
        value = $.trim($el.val())
        checks = $el.data('mc-validate')
        missing_value = (/required/.test(checks) and value == '')
        bad_phone = (/phone/.test(checks) and not /^(1[ -\.]?)?(\(?[2-9]\d{2}\)?[ -\.]?)\d{3}[ -\.]?\d{4}$/.test(value))
        bad_amount = (/amount/.test(checks) and not /^\$?[\d.]+$/.test(value))
        if missing_value or bad_phone or bad_amount
          $el.addClass('mc-error')
          valid = false
        else
          $el.removeClass('mc-error')
        true
      valid

  MC = @__MC__ = $.extend(@__MC__ || {}, {
    WidgetModel: WidgetModel
    WidgetView: WidgetView
    installWidget: (model, view) ->
      if model.get('include_styles') or @forceInstallStyles?
        $("head").prepend model.get('style_link_tag')
      $link = $("a[data-mc-widget-id=#{model.get('id')}]")
      $link.replaceWith(view.$template)
      if $.isFunction(MC.installWidgetCallback)
        MC.installWidgetCallback(model, view)
      else
        window.placeholderShiv();
        view.bindFormHandler()
      @model = model
      @view = view
      $(@model).trigger('mc:updated')
  })
)(jQuery, @MCwidgetControls)
