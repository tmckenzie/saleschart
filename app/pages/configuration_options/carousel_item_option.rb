module ConfigurationOptions
  class CarouselItemOption
    def self.build_for(media_items, captions={})
      media_items.to_a.map do |option|
        next if option.respond_to?(:display_value) && option.display_value.nil?
        OpenStruct.new(
          id: option.id,
          position: option.position,
          caption: captions[option.id.to_s]
        ).tap do |item|
          item.url, item.name = if option.is_a?(ComponentImage)
            image = option.image
            item.send("image?=", true)
            [image.url(:original), image.original_filename]
          elsif option.value_type == NposCustomFormFieldTemplateValue::IMAGE_TYPE
            image = ComponentImage.find(option.display_value).image
            item.send("image?=", true)
            [image.url(:original), image.original_filename]
          else
            item.send("video?=", true)
            [option.display_value, "Video URL"]
          end
        end
      end.compact
    end
  end
end