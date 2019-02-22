require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module MMP
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/"] - Dir["#{config.root}/lib/generators/**/"]
    config.autoload_paths += Dir["#{config.root}/app/models/filters/**/"]
    config.autoload_paths += Dir["#{config.root}/app/exhibits/"]
    config.autoload_paths += Dir["#{config.root}/lib/one_time/"]
    config.autoload_paths += Dir["#{config.root}/lib/extension/"]
    config.autoload_paths += Dir["#{config.root}/app/components/"]
    config.autoload_paths += Dir["#{config.root}/app/pages/**"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns/"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns/"]
    config.autoload_paths += Dir["#{config.root}/app/exhibits1/concerns"]


    # config.eager_load_paths << Rails.root.join('app', 'decorators', 'concerns')
    config.action_controller.permit_all_parameters = true

    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # CSS & JS Manifest files that should be precompiled
    config.assets.precompile += ['admin_build.css', 'mc-gen-message-builder.css', 'private/default_stylesheets.css', 'registration/manifest.css',
                                 'free_registration/manifest.css', 'inactive_keyword/inactive_keyword.css',
                                 'mobile/manifest.css','public/default_stylesheets.css',
                                 'widgets/widget-modal.css', 'widgets/pledging-widget.css', 'public/themes/original.css',
                                 'admin_build.js', 'graph.js', 'modularized/workbench.js', 'app_build.js',
                                 'simple_require_jquery.js', 'modularized/manifest.js', 'mobile.js',
                                 'private/default_javascripts.js']


    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
