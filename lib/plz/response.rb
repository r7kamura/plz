module Plz
  class Response
    TEMPLATE = <<-EOS.strip_heredoc
      HTTP/1.1 %{status}
      %{headers}

      %{body}
    EOS

    # @param [Faraday::Response]
    def initialize(raw)
      @raw = raw
    end

    # @param options [Hash] Options to change renderer behavior
    # @return [String]
    def render(options = {})
      TEMPLATE % {
        status: status,
        headers: headers.join("\n"),
        body: body,
      }
    end

    private

    # @return [Array<String>]
    # @example
    #   headers #=> ["Content-Type: application/json"]
    def headers
      @raw.headers.sort_by do |key, value|
        key
      end.map do |key, value|
        "%{key}: %{value}" % {
          key: Rainbow(key.split("-").map(&:camelize).join("-")).underline,
          value: Rainbow(value).green,
        }
      end
    end

    # @return [String]
    def status
      Rainbow("#{status_code} #{status_in_words}").bright
    end

    # @return [Fixnum]
    def status_code
      @raw.status
    end

    # @return [String] Words for its status code
    def status_in_words
      Rack::Utils::HTTP_STATUS_CODES[@raw.status]
    end

    # @return [String]
    def body
      Rouge::Formatters::Terminal256.format(
        Rouge::Lexers::Javascript.new.lex(plain_body),
        theme: "github"
      )
    end

    # @return [String] Pretty-printed JSON body
    def plain_body
      JSON.pretty_generate(@raw.body)
    end
  end
end
