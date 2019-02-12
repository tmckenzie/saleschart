class SolrBase

  #SERVER_ADDR  = "http://10.0.1.22"
  #SERVER_PORT = "8983"
  #SERVER_URL  = "#{SERVER_ADDR}:#{SERVER_PORT}"

  def initialize

  end

  def connection
    "#{CONFIG[:solr][:host]}:#{CONFIG[:solr][:port]}"
  end
end