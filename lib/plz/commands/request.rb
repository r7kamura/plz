module Plz
  module Commands
    class Request
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
        catch :skip_renderer do
          @process_response_block.call(response) if @process_response_block
          puts ResponseRenderer.call(
            status: response.status,
            headers: response.headers,
            body: response.body,
            response_header: flag_to_show_response_header,
            response_body: flag_to_show_response_body,
            color: flag_to_color_response,
          )
        end
      rescue Faraday::ConnectionFailed => exception
        puts exception
      end

      # The provided block will be called with the Faraday connection object.
      # It may be used to set up more middleware.
      def customize_client(&block)
        @customize_client_block = block
      end

      # The provided block will be called with the Faraday response object
      # before the response renderer. If it throws :skip_renderer, the response
      # renderer will not be called afterward.
      def process_response(&block)
        @process_response_block = block
      end

      private

      # @return [Faraday::Connection]
      def client
        Faraday.new(url: @base_url) do |connection|
          connection.request :json
          @customize_client_block.call(connection) if @customize_client_block
          connection.response :json, content_type: /\bjson$/
          connection.adapter Faraday.default_adapter
        end
      end

      # @return [true, false]
      def flag_to_show_response_header
        !@options[:"no-response-header"]
      end

      # @return [true, false]
      def flag_to_show_response_body
        !@options[:"no-response-body"]
      end

      # @return [true, false]
      def flag_to_color_response
        !@options[:"no-color"]
      end
    end
  end
end
