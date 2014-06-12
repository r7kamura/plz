module Plz
  class Response
    TEMPLATE = <<-EOS.strip_heredoc
      HTTP/1.1 %{status_code} %{status_in_words}
      %{headers}

      %{body}
    EOS

    # @param [Faraday::Response]
    def initialize(raw)
      @raw = raw
    end

    # @return [String]
    def to_s
      TEMPLATE % {
        status_code: status_code,
        status_in_words: status_in_words,
        headers: headers.join("\n"),
        body: body,
      }
    end

    private

    # @return [Array<String>]
    def headers
      @raw.headers.sort_by do |key, value|
        key
      end.map do |key, value|
        "%{key}: %{value}" % {
          key: key.split("-").map(&:camelize).join("-"),
          value: value,
        }
      end
    end

    # @return [Fixnum]
    def status_code
      @raw.status
    end

    # @return [String] Words for its status code
    def status_in_words
      Rack::Utils::HTTP_STATUS_CODES[status_code]
    end

    # @return [String]
    def body
      JSON.pretty_generate(@raw.body)
    end
  end
end
