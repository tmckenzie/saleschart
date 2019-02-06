module Elements
  module Standard
    class CarouselElement < Elements::BaseElement
      default_renderer Pages::Components::ComponentsExhibit::CAROUSEL_RENDERER
      display_name "Carousel"

      hideable false

      DO_NOT_AUTOPLAY = "Don't Autoplay"
      AUTOPLAY_WITH_AUDIO = "Autoplay with Audio"
      AUTOPLAY_WITHOUT_AUDIO = "Autoplay without Audio"
      AUTOPLAY_OPTIONS = [AUTOPLAY_WITHOUT_AUDIO, AUTOPLAY_WITH_AUDIO, DO_NOT_AUTOPLAY]

      SHOW_FLOATING_VIDEO_ON_SCROLL = "Show Floating Video When out of View"
      PAUSE_VIDEO_ON_SCROLL = "Pause Video When out of View"
      VIDEO_ON_SCROLL_OPTIONS = [PAUSE_VIDEO_ON_SCROLL]

      element_options do |option_builder|
        option_builder.carousel :carousel
        option_builder.boolean :autoscroll, default: true
        option_builder.string :autoscroll_interval, default: 5000, label_hint: "(in milliseconds)"
        option_builder.boolean :wrap
        option_builder.collection :autoplay,
          default_value: 0,
          label_hint: "(When first carousel item is a video)",
          items: AUTOPLAY_OPTIONS.map.with_index {|option, index| [option, index] },
          except: Theme::ORIGINAL
        option_builder.collection :video_scroll_behavior,
          default_value: 0,
          items: VIDEO_ON_SCROLL_OPTIONS.map.with_index {|option, index| [option, index] },
          except: Theme::ORIGINAL
      end

      def autoplay_with_audio?
        autoplay.to_i == AUTOPLAY_OPTIONS.index(AUTOPLAY_WITH_AUDIO)
      end

      def autoplay_without_audio?
        autoplay.to_i == AUTOPLAY_OPTIONS.index(AUTOPLAY_WITHOUT_AUDIO)
      end

      def autoplay?
        autoplay_without_audio? || autoplay_with_audio?
      end

      def sticky_video?
        video_scroll_behavior.to_i == VIDEO_ON_SCROLL_OPTIONS.index(SHOW_FLOATING_VIDEO_ON_SCROLL)
      end
    end
  end
end