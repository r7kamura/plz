module Plz
  class Command
    # @param headers [Hash]
    # @param params [Hash]
    # @param method [String]
    # @param base_url [String]
    # @param path [String]
    # @param options [Hash]
    def initialize(headers: nil, params: nil, method: nil, base_url: nil, path: nil, options: nil)
      @headers = headers
      @params = params
      @method = method
      @base_url = base_url
      @path = path
      @options = options
    end

    # Sends an HTTP request and logs out the response
    def call
      response = client.send(@method.downcase, @path, @params, @headers)
      puts ResponseRenderer.call(
        status: response.status,
        headers: response.headers,
        body: response.body,
        response_header: flag_to_show_response_header,
      )
    rescue Faraday::ConnectionFailed => exception
      puts exception
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

    # @return [true, false]
    def flag_to_show_response_header
      !!@options[:"response-header"]
    end
  end
end
