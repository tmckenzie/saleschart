module Elements
  module Custom
    class ImageElement < Elements::BaseElement
      add_config :button, default: false
      default_renderer :image

      requirable false

      element_options do |option_builder|
        option_builder.image :image, default_value: File.new(Rails.root.join('app', 'assets', 'images', 'placeholder_image.png'))
      end

      def image_url
        image.try(:url, :large)
      end
      alias_method :url, :image_url
    end
  end
end