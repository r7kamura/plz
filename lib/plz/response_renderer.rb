module Plz
  class ResponseRenderer
    # Shortcut for #call method
    def self.call(*args)
      new(*args).call
    end

    # @param status [Fixnum] Status code
    # @param headers [Hash] Response header fields
    # @param body [Array, Hash] JSON decoded response body
    # @param response_header [true, false] Flag to show response header
    # @param response_body [true, false] Flag to show response body
    # @param color [true, false] Flag to color response body
    def initialize(status: nil, headers: nil, body: nil, response_header: nil, response_body: nil, color: nil)
      @status = status
      @headers = headers
      @body = body
      @show_response_header = response_header
      @show_response_body = response_body
      @color_response = color
    end

    # Renders response with given options
    # @return [String] Rendered output
    def call
      template % {
        status: status,
        headers: headers,
        body: body,
      }
    end

    private

    # @return [String] Template for embedding variables, changing by options
    def template
      str = ""
      str << <<-EOS.strip_heredoc if @show_response_header
        HTTP/1.1 %{status}
        %{headers}
      EOS
      str << "\n" if @show_response_header && @show_response_body
      str << "%{body}" if @show_response_body
      str
    end

    # @return [String]
    # @example
    #   headers #=> ["Content-Type: application/json"]
    def headers
      @headers.sort_by do |key, value|
        key
      end.map do |key, value|
        "%{key}: %{value}" % {
          key: Rainbow(key.split("-").map(&:camelize).join("-")).underline,
          value: Rainbow(value).green,
        }
      end.join("\n")
    end

    # @return [String]
    def status
      Rainbow("#{@status} #{status_in_words}").bright
    end

    # @return [String] Words for its status code
    def status_in_words
      Rack::Utils::HTTP_STATUS_CODES[@status]
    end

    # @return [String]
    def body
      if @color_response
        Rouge::Formatters::Terminal256.format(
          Rouge::Lexers::Javascript.new.lex(plain_body),
          theme: "github"
        )
      else
        plain_body
      end
    end

    # @return [String] Pretty-printed JSON body
    def plain_body
      JSON.pretty_generate(@body) + "\n"
    end

    # Overridden to disable coloring
    def Rainbow(str)
      if @color_response
        super
      else
        Rainbow::NullPresenter.new(str.to_s)
      end
    end
  end
end
