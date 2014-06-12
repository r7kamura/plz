module Plz
  class Command
    # @param action_name [String]
    # @param target_name [String]
    # @param headers [Hash]
    # @param params [Hash]
    # @param schema [Hash]
    def initialize(action_name: nil, target_name: nil, headers: nil, params: nil, schema: nil)
      @action_name = action_name
      @target_name = target_name
      @headers = headers
      @params = params
      @schema = schema
    end

    # TODO
    # Sends an HTTP request and logs out the response
    def call
      puts client.send(method, path, @params, @headers).body
    end

    private

    # @return [String]
    def path
      current_link.href
    end

    # @return [Symbol]
    def method
      current_link.method
    end

    # @return [JsonSchema::Schema::Link, nil]
    def current_link
      @current_link ||= json_schema.properties.find do |key, schema|
        if key == @target_name
          schema.links.find do |link|
            if link.href && link.method && link.title.underscore == @action_name
              return link
            end
          end
        end
      end
    end

    # @return JsonSchema::Schema
    # @raise [JsonSchema::SchemaError]
    def json_schema
      @json_schema ||= JsonSchema.parse!(@schema).tap(&:expand_references!)
    end

    # @return [Faraday::Connection]
    def client
      Faraday.new(url: base_url) do |connection|
        connection.request :json
        connection.adapter :net_http
      end
    end

    # Extracts the base url of the API
    # @return [String, nil]
    def base_url
      json_schema.links.find do |link|
        if link.href && link.rel == "self"
          return link.href
        end
      end
    end
  end
end
