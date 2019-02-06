module Elements
  module Standard
    class MainVideoElement < Elements::BaseElement
      default_renderer :video

      hideable false

      element_options do |option_builder|
        option_builder.string :video_url
      end
      alias_method :url, :video_url
    end
  end
end