# Provides the query methods for Apache solr

class SolrQueryManager < SolrBase

  REQUEST_TIMEOUT_SECS = 2

  def self.new_instance
    if Rails.env.development?
       MockQueryManager.new
    else
      SolrQueryManager.new
    end
  end

  def initialize()
  end

  def npos_date_range_query(npo_ids, start_date, end_date, recurring_only = false)
    start_date ||= Time.now.beginning_of_year
    end_date ||= Time.now.end_of_year
    query_data = date_range_query_document("npo_id:(#{npo_ids.join(' ')})", start_date, end_date, recurring_only)
    response = {}
    begin
      url = "#{connection}/solr/txns/select" + query_data[:url_params]
      Rails.logger.info("url: #{URI.encode(url)}")
      response = RestClient::Request.execute(method: :post,
                                             url: URI.encode(url),
                                             payload: query_data[:query_document].to_json,
                                             headers: { content_type: :json, accept: :json },
                                             open_timeout: REQUEST_TIMEOUT_SECS)
      Rails.logger.info("solr response: #{response}")
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response

  end

  def npo_date_range_query(npo_id, start_date, end_date, recurring_only = false)

    start_date ||= Time.now.beginning_of_year
    end_date ||= Time.now.end_of_year

    # url = date_range_query_url("npo_id:#{npo_id}", start_date, end_date, recurring_only)
    query_data = date_range_query_document("npo_id:#{npo_id}", start_date, end_date, recurring_only)


    response = {}
    begin
      url = "#{connection}/solr/txns/select" + query_data[:url_params]
      Rails.logger.info("url: #{URI.encode(url)}")
      response = RestClient::Request.execute(method: :post,
                                             url: URI.encode(url),
                                             payload: query_data[:query_document].to_json,
                                             headers: { content_type: :json, accept: :json },
                                             open_timeout: REQUEST_TIMEOUT_SECS)
      Rails.logger.info("solr response: #{response}")
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response

  end

  def campaign_date_range_query(campaign_id, start_date, end_date)

    start_date ||= Time.now.beginning_of_year
    end_date ||= Time.now.end_of_year

    url = date_range_query_url("campaign_id:#{campaign_id}", start_date, end_date)

    response = {}
    begin
      response = RestClient::Request.execute(method: :get, url: URI.encode(url), open_timeout: REQUEST_TIMEOUT_SECS)
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response

  end

  def npo_yearly_donations(npo_id)
    url = yearly_donation_count_and_amount_query_url("npo_id:#{npo_id}")
    response = {}
    begin
      response = RestClient::Request.execute(method: :get, url: URI.encode(url), open_timeout: REQUEST_TIMEOUT_SECS)
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response

  end

  def npo_donations_per_year(npo_id)
    url = npo_donations_per_year_query_url("npo_id:#{npo_id}")
    response = {}
    begin
      response = RestClient::Request.execute(method: :get, url: URI.encode(url), open_timeout: REQUEST_TIMEOUT_SECS)
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response

  end

  def npo_recurring_frequency_totals(npo_id)
    url = yearly_txns_freqency_query_url(npo_id)

    response = {}
    begin
      Rails.logger.info("url: #{URI.encode(url)}")
      response = RestClient::Request.execute(method: :get, url: URI.encode(url), open_timeout: REQUEST_TIMEOUT_SECS)
      return JSON.parse(response)
    rescue RestClient::RequestTimeout => ex
      Rails.logger.info("RestClient timeout exception after #{REQUEST_TIMEOUT_SECS} seconds: #{ex.message}")
    end

    return response
  end


  def date_range_query_url(query, start_date, end_date, recurring_only = false)
    stats_segment = "stats.facet=billing_status&stats.facet=created_at_month&stats.facet=created_at_day&stats.field=amount&stats=true"
    query_url = "#{connection}/solr/txns/select?fq=created_at_date:[<START_DATE> TO <END_DATE>]"
    query_url += "&fq=is_recurring_donation:1" if recurring_only
    url = query_url.gsub("<START_DATE>", start_date.strftime("%Y-%m-%dT00:00:00.000Z"))
    url = url.gsub("<END_DATE>", end_date.strftime("%Y-%m-%dT00:00:00.000Z"))
    url += "&q=#{query}&#{stats_segment}"
    url
  end

  def date_range_query_document(query, start_date, end_date, recurring_only=false)

    filter = "created_at_date: [#{start_date.strftime("%Y-%m-%dT00:00:00.000Z")} TO #{end_date.strftime("%Y-%m-%dT00:00:00.000Z")}]"

    query_document = {
        "query" => query,
        "filter" => filter
    }

    query_document.compare_by_identity
    query_document = recurring_donation_filter(query_document) if recurring_only

    query_params = "?stats=true"
    query_params += "&stats.field=amount"
    query_params += "&stats.facet=created_at_day"
    query_params += "&stats.facet=created_at_month"
    query_params += "&stats.facet=npo_id"
    query_params += "&stats.facet=billing_status"
    query_params += "&fq=transaction_source:online"
    query_params += "&fq=billing_status:settled or billing_status:submitted_for_settlement"
    query_params += "&rows=400"

    Rails.logger.info("query_document: #{query_document.to_json}")

    return { :query_document => query_document, :url_params => query_params }

  end

  def recurring_donation_filter(query_doc)
    query_doc["filter"] = "is_recurring_donation:1"
    return query_doc
  end

  def yearly_donation_count_and_amount_query_url(query)
    stats_segment ="stats.facet=billing_status&stats.facet=created_at_year&stats.field=amount&stats=true"
    url = "#{connection}/solr/txns/select?fq=billing_status:settled or billing_status:submitted_for_settlement"
    url += "&fq=transaction_source:online"
    url += "&q=#{query}&#{stats_segment}"
    url += "&rows=400"
    url
  end

  def yearly_txns_freqency_query_url(npo_id)
    # http://10.81.8.8:8983/solr/txns/select?facet.pivot={!stats=t1}created_at_year,recurring_frequency&facet=true&fq=npo_id:1&q=is_recurring_donation:true&stats.field={!tag=t1}amount&stats=true
    #
    stats_segment="stats.field={!tag=t1}amount&stats=true"
    facet_segment="facet.pivot={!stats=t1}created_at_year,recurring_frequency&facet=true"
    query="q=npo_id:#{npo_id}"
    url = "#{connection}/solr/txns/select?#{query}&#{stats_segment}&#{facet_segment}"
    url
  end

  def npo_donations_per_year_query_url(query)
    stats_segment ="stats.facet=created_at_year&stats.field=amount&stats=true"
    url = "#{connection}/solr/txns/select?fq=billing_status:settled or billing_status:submitted_for_settlement"
    url += "&fq=transaction_source:online"
    url += "&q=#{query}&#{stats_segment}"
    url += "&rows=400"
  end


end