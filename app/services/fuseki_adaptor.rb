require "net/http"

require "iq_triplestorage"

class IqTriplestorage::FusekiAdaptor < IqTriplestorage::BaseAdaptor

  def initialize(host, options={})
    super
    # validate to avoid nasty errors
    raise(ArgumentError, "username must not be nil") if @username.nil?
  end

  def reset(uri)
    return sparql_pull("CLEAR GRAPH <#{uri}>") # XXX: s/CLEAR/DROP/ was rejected (405)
  end

  # expects a hash of N-Triples by graph URI
  def batch_update(triples_by_graph)
    # apparently Virtuoso gets confused when mixing CLEAR and INSERT queries,
    # so we have to do use separate requests

    reset_queries = triples_by_graph.keys.map do |graph_uri|
      "CLEAR GRAPH <#{graph_uri}>" # XXX: duplicates `reset`
    end
    success = sparql_query(reset_queries)
    return false unless success

    insert_queries = triples_by_graph.map do |graph_uri, ntriples|
      "INSERT IN GRAPH <#{graph_uri}> {\n#{ntriples}\n}"
    end
    success = sparql_query(insert_queries)

    return success
  end

  # uses push method if `rdf_data` is provided, pull otherwise
  def update(uri, rdf_data=nil, content_type=nil)
    reset(uri)

    if rdf_data
      res = sparql_push(uri, rdf_data.strip, content_type)
    else
      res = sparql_pull(%{LOAD "#{uri}" INTO GRAPH <#{uri}>})
    end

    return res
  end

  def sparql_push(uri, rdf_data, content_type)
    raise TypeError, "missing content type" unless content_type

    filename = uri.gsub(/[^0-9A-Za-z]/, "_") # XXX: too simplistic?
    path = "/DAV/home/#{@username}/rdf_sink/#{filename}"

    res = http_request("PUT", path, rdf_data, { # XXX: is PUT correct here?
      "Content-Type" => content_type
    })

    return res.code == "201"
  end

  def sparql_pull(query)
    path = "/DAV/home/#{@username}/rdf_sink" # XXX: shouldn't this be /sparql?
    res = http_request("POST", path, query, {
      "Content-Type" => "application/sparql-query"
    })
    return res.code == "200" # XXX: always returns 409
  end

  # query is a string or an array of strings
  def sparql_query(query)
    query = query.join("\n\n") + "\n" rescue query
    path = "/DAV/home/#{@username}/query"

    res = http_request("POST", path, query, {
      "Content-Type" => "application/sparql-query"
    })

    return res.code == "201"
  end

end