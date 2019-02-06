class NpoFundraisersExhibit < Exhibit

  FUNDRAISERS_TABLE = "fundraises-table"

  def render_fundraisers_table(async: false)
    if async
      render_async view.npo_peer_fundraisers_path(campaigns_keyword_id: model.campaigns_keyword_id, format: :js)
    else
      render FUNDRAISERS_TABLE,
             defaults: { partial: "peer_fundraisers/my_fundraisers_table" },
             fundraisers: model.fundraisers.paginate(page: view.params[:page], per_page: 30)
    end
  end

end