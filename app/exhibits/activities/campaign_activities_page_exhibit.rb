module Activities
  class CampaignActivitiesPageExhibit < Blocks.builder_class
    include SimplePageExhibitConcerns

    alias_method :activities, :view_model

    def render_actions(object)
      # TODO: use content_tag wrapper once blocks is upgraded to 3.1
      render wrap_all: ACTION_DROPDOWN_MENU,
             collection: object.actions,
             wrapper: lambda { |content_block| content_tag :li, &content_block } do |action|
          view.link_to action[:path], target: action[:target] do
            content_tag(:i, '', class: "fa fa-fw #{action[:icon_class]}") + " " + action[:label]
          end
      end
    end
  end
end