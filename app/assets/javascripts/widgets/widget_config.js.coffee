$(document).ready ->
  $('[data-autoupdate-widget]').each (i, form) ->
    $form = $(form)
    $.each([
      # common widget fields
      {selector: 'input.layout_field', key: 'layout'}
      {selector: 'textarea.message_field:enabled', event: 'keyup', key: 'message'}
      {selector: 'input.background_color_field', key: 'background_color'}
      # messaging widget fields
      {selector: 'input.frequency_count_field', key: 'frequency_count'}
      {selector: 'input.frequency_period_field', key: 'frequency_period'}
    ], (i, config) ->
      $form.find(config.selector).on((config.event or 'change' or 'click'), (e) ->
        $target = $(e.target)
        MCwidgetConfig.widgetOptions[config.key] = if $target.get(0).type == 'radio'
          $target.prop('value')
        else
          $target.val()
        MCwidgetConfig.updateDomForAdmin(MCwidgetConfig.widgetOptions)
      )
    )

@__MC__ = $.extend(@__MC__ || {}, {
  WidgetControls: class WidgetControls
    constructor: (model, config, context=document) ->
      @model = model
      for field in config
        $(field.selector, context).on('keyup click', @handler(field))
    handler: (field) ->
      enclosedModel = @model
      (e) ->
        options = {}
        value = if (e.target.type != 'checkbox')
          e.target.value
        else
          $(e.target).prop('checked') == true
        options[field.key] = value
        enclosedModel.set(options)

  exampleMarkup: (model, view) ->
    $template = view.$template.clone()
    layout = model.get('layout')
    removeThese = (it for it in [
      '[data-mc-dialog]'
      '[data-mc-layout=horizontal]'
      '[data-mc-layout=vertical]'
      '[data-mc-layout=slimline]'
    ] when (it.indexOf(model.get('layout')) < 0)).join(',')
    $template.find(removeThese).remove()
    $template.find([
      '[data-mc-trigger-confirmation-button]'
      '[data-mc-cancel-submission-button]'
      '[data-mc-trigger-submission-button]'
      '[data-mc-classes]'
      '[data-mc-class]'
      '[data-mc-toggle]'
      '[data-mc-attr]'
      '[data-mc-model]'
      '[data-mc-form]'
      '[data-mc-widget-id-field]'
      '[data-mc-fields]'
      '[data-mc-validate]'
      '[data-mc-response]'
      '[data-mc-layout]'
      '[data-mc-block]'
    ].join(',')).each ->
      $(this).removeAttr(name) for name in (node.name for node in @attributes when /^data-mc/.test(node.name))
    $template.html()

  forceInstallStyles: true

  installWidgetCallback: (model, view) ->
    exampleMarkup = @exampleMarkup
    view.disableForm()
    model.observer ->
      $label = $('[data-slimline-popup-label]')
      if model.is_slimline() then $label.show() else $label.hide()
      if (model.get('include_styles'))
        $('#widget_layout_template pre').text('').parent().hide();
      else
        $('#widget_layout_template pre').text(exampleMarkup(model, view)).parent().show();
    new WidgetControls model, @adminControlsConfiguration
})
