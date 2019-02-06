class PeerFundraiserActivityExhibit < ActivityExhibit
  attr_accessor :status_filter, :npo_fundraisers_exhibitor

  delegate :configuration_sections,
           :default_tab_options,
       to: :page_view_model

  delegate :render_fundraisers_table, to: :npo_fundraisers_exhibitor

  DASHBOARD = "my-fundraisers"
  FUNDRAISING_PAGE = "fundraising-page"

  def initialize(model, view)
    super model, view
    self.npo_fundraisers_exhibitor = NpoFundraisersExhibit.new(model.fundraisers_filter_view, view)
  end

  def config_page_navigation
    super
    if !new?
      self.status_filter = view.instance_variable_get(:@status_filter)
      ck = campaigns_keyword
      page.add_section_from(id: DASHBOARD, heading: 'Fundraiser Dashboard', action: 'my_fundraisers', default: true)
      page.add_section_from(id: FUNDRAISING_PAGE, heading: 'Fundraising Page', action: 'setup_fundraising_page')
      page.add_section_from(id: 'online-forms', heading: 'Online Forms', action: 'setup_online_forms')
      page.add_section_from(id: 'donor-experience', heading: 'Mobile Experience', action: 'setup_mobile_experience')
      page.add_section_from(id: 'my-teams', heading: 'Teams', action: 'my_teams')
      page.add_section_from(id: 'categories-form', heading: 'Team Categories', action: 'categories_form')
      page.add_section_from(id: 'signup-form', heading: 'Sign Up Form', action: 'signup_form')
      page.add_section_from(id: SOCIAL_MEDIA_SETTINGS, heading: 'Social Media Settings', action: 'social_media')
      page.add_section_from(id: 'offline-form', heading: 'Enter Offline Donation', action: 'offline_donations')
    end
    page.add_section_from(id: 'keyword', heading: 'Keyword', action: 'setup_keyword')
  end

  def setup_keyword
    {
        partial: "activities/peer_fundraiser/setup_keyword",
        locals: {
            active: new? ? 'active' : '',
            form_attributes: new? ? {
                as: 'activity',
                url: view.activities_path(type: 'social_giving')
            } : {
                as: 'activity',
                url: view.activity_path,
                method: :put,
                remote: true
            },
            activity_config: model.activity_config,
            keyword_extras: "activities/peer_fundraiser/setup_keyword_extras",
            keyword_header: "activities/setup_keyword_header",
            existing_keywords: view.current_npo.social_giving_keywords.live
        }
    }
  end

  def my_teams
    {
        partial: "activities/peer_fundraiser/my_teams",
        locals: {
            active: new? ? '' : 'active',
            peer_fundraiser_setting: campaigns_keyword.peer_fundraiser_setting,
            campaigns_keyword: campaigns_keyword,
            teams: model.peer_fundraiser_teams.paginate(page: view.params[:page], per_page: 30)
        }
    }
  end

  def setup_fundraising_page
    {
        partial: "activities/peer_fundraiser/setup_fundraising_page",
        locals: {
          page_view_model: ::Pages::ConfigView.new(view, page_model)
        }
    }
  end


  def categories_form
    campaigns_keyword.peer_fundraiser_setting.update_attributes(tmp_attrs: nil, tmp_inspirational_img: nil)
    {
        partial: "activities/peer_fundraiser/categories_form",
        locals: {
            peer_fundraiser_setting: campaigns_keyword.peer_fundraiser_setting,
            categories: model.categories.paginate(page: view.params[:page], per_page: 30),
            campaigns_keyword: campaigns_keyword
        }
    }
  end

  def signup_form
    fundraiser_sign_up_form = campaigns_keyword.find_or_create_fundraiser_sign_up_form
    {
        partial: "activities/peer_fundraiser/signup_form",
        locals: {
            form: fundraiser_sign_up_form,
            campaigns_keyword: campaigns_keyword
        }
    }
  end

  def offline_donations
    per_page = view.current_npo.keyword_pagination_count.to_i <= 0 ? 30 : view.current_npo.keyword_pagination_count.to_i
    offline_donations = campaigns_keyword.offline_transactions.order('created_at desc').paginate(page: params[:page], per_page: per_page)
    {
      partial: "activities/offline_donation",
      locals: {
        campaigns_keyword: campaigns_keyword,
        fundraisers: campaigns_keyword.peer_fundraisers_by_name,
        teams: campaigns_keyword.peer_fundraiser_teams_by_name,
        offline_donations: offline_donations
      }
    }
  end

  def setup_mobile_experience
    partial = "activities/setup_mobile_experience"
    {
        partial: partial,
        locals: {
            activity_config: model.activity_config,
            campaigns_keyword: campaigns_keyword
        }
    }
  end

  def form_list
    {
        partial: "activities/form_list",
        locals: {
            campaigns_keyword: campaigns_keyword
        }
    }
  end

  def setup_modals
    after_all CONTENT, partial: 'components/modal_edit_fundraisers'
    super
  end

  def layout
    if section_locals[:id] == "my-fundraisers"
      "admin"
    else
      super
    end
  end

  def page_model
    @page_model ||= campaigns_keyword.find_or_create_crowdfunding_page
  end

  protected

  def setup_page_components
    define LayoutBuilder::CONTENT, wrap_all: :container, fluid: true
    define PAGE, with: current_page_section.id if block_defined?(current_page_section.id)

    super
  end

  def setup_components
    define DASHBOARD, partial: "activities/peer_fundraiser/my_fundraisers"
    define FUNDRAISING_PAGE, partial: "activities/peer_fundraiser/setup_fundraising_page"

    super
    if !new? && model.activity_config.campaigns_keyword.active?
      append NAVIGATION,
        partial: "activities/peer_fundraiser/display_links",
        campaigns_keyword: campaigns_keyword
    end
  end
end
