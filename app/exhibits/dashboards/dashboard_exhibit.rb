module Dashboards
  class DashboardExhibit < AdminExhibit
    attr_accessor :view_model

    def initialize(view_model, view)
      self.view_model = view_model
      super
    end

    alias_method :context, :view
    alias_method :model, :view_model

    def current_month
      Date::MONTHNAMES[Date.current.month]
    end

    def previous_month
      month = Date.current.month
      month == 1 ? Date::MONTHNAMES[12] : Date::MONTHNAMES[month - 1]
    end

    def deferred_call_for(method_name)
      "<span class='loading' data-deferred='/dashboard/deferred?key=#{method_name.to_s}'>loading...</span>".html_safe
    end

    def send_deferred_key(key)
      key_sym = key.to_sym
      return unless known_deferred_methods.include?(key_sym)
      send key_sym
    end

    def known_deferred_methods
      [
          :total_messages_sent_this_month,
          :total_messages_sent,
          :total_subscribers
      ]
    end

    def total_messages_sent_this_month
      context.number_with_delimiter(view_model.total_messages_sent_this_month)
    end

    def total_messages_sent
      context.number_with_delimiter(view_model.total_messages_sent)
    end

    def total_subscribers
      context.number_with_delimiter(view_model.total_subscribers)
    end

    def render_panel(panel)
      locals = {rows: panel[:rows], exhibitor: self}.merge(panel.has_key?(:locals) ? panel[:locals] : {})
      render(locals.merge(partial: panel[:partial])) unless panel[:partial].nil?
    end

    def render_row(row)
      locals = row.has_key?(:locals) ? row[:locals].merge({exhibitor: self}) : {locals: {exhibitor: self}}
      render(locals.merge(partial: row[:partial])) unless row[:partial].nil?
    end

    # TODO: ahunter - remove this method once all dashboards are using the admin layout
    def layout
      "application"
    end

    # TODO: ahunter - remove this method once all dashboards are using the admin layout
    def action
      "index"
    end

    def setup_components
      raise NotImplementedError
    end
  end
end