module Plz
  class Command
    # @param headers [Hash]
    # @param params [Hash]
    # @param method [String]
    # @param base_url [String]
    # @param path [String]
    def initialize(headers: nil, params: nil, method: nil, base_url: nil, path: nil)
      @headers = headers
      @params = params
      @method = method
      @base_url = base_url
      @path = path
    end

    # Sends an HTTP request and logs out the response
    def call
      raw = client.send(@method.downcase, @path, @params, @headers)
      puts Response.new(raw).render
    end

    private

    # @return [Faraday::Connection]
    def client
      Faraday.new(url: @base_url) do |connection|
        connection.request :json
        connection.response :json
        connection.adapter :net_http
      end
    end
  end
end
