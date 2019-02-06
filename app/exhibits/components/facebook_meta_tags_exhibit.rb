class Components::FacebookMetaTagsExhibit < Blocks.builder_class
  TAGS = :tags
  META_TAG = :meta_tag
  TITLE_TAG = "og:title"
  DESCRIPTION_TAG = "og:description"
  URL_TAG = "og:url"
  IMAGE_TAG = "og:image"

  attr_accessor :view_model

  def initialize(view, view_model)
    self.view_model = view_model
    super view
    setup_components
  end

  def render_components
    render TAGS do
      buffer = render(TITLE_TAG)
      buffer << render(URL_TAG)
      buffer << render(IMAGE_TAG)
      buffer << render(DESCRIPTION_TAG)
    end
  end

  private
  def setup_components
    define META_TAG do |options|
      if options[:content]
        view.tag :meta, property: options.block_name, content: options[:content]
      end
    end

    define TITLE_TAG,
      with: META_TAG,
      content: view_model.facebook_share_title
    define DESCRIPTION_TAG,
      with: META_TAG,
      content: view_model.facebook_share_description
    define URL_TAG,
      with: META_TAG,
      content: view_model.facebook_share_url
    define IMAGE_TAG,
      with: META_TAG,
      content: view_model.facebook_share_image
  end
end