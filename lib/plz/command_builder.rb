module Plz
  class CommandBuilder
    SCHEMA_FILE_PATH_PATTERN = "schema.{json,yml}"

    # Builds callable command object from given ARGV
    # @return [Plz::Command, Plz::ErrorCommand]
    # @note This is a shortcut for #call method
    # @example
    #   Plz::CommandBuilder.call(ARGV).call
    def self.call(arguments)
      new(arguments).call
    end

    delegate(
      :action_name,
      :target_name,
      :headers,
      :params,
      :has_invalid_json_input?,
      to: :arguments,
    )

    # @param argv [Array<String>] Raw ARGV
    def initialize(argv)
      @argv = argv
    end

    # @return [Plz::Command] Callable command object
    def call
      case
      when !has_schema_file?
        Commands::SchemaFileNotFound.new
      when !has_decodable_schema_file?
        Commands::UndecodableSchemaFile.new(pathname: schema_file_pathname)
      when !has_valid_schema_file?
        Commands::InvalidSchema.new(pathname: schema_file_pathname, error: @json_schema_error)
      when !has_base_url?
        Commands::BaseUrlNotFound.new(pathname: schema_file_pathname)
      when has_help?
        Commands::Help.new(options: options, schema: json_schema)
      when !has_action_name?
        Commands::NoActionName.new
      when !has_target_name?
        Commands::NoTargetName.new
      when !has_link?
        Commands::LinkNotFound.new(
          pathname: schema_file_pathname,
          action_name: action_name,
          target_name: target_name,
        )
      when has_invalid_json_input?
        Commands::InvalidJsonFromStdin.new
      when has_unparsable_json_param?
        Commands::UnparsableJsonParam.new(error: @json_parse_error)
      else
        Commands::Request.new(
          method: method,
          base_url: base_url,
          path: path,
          headers: headers,
          params: request_params,
          options: options,
        )
      end
    end

    private

    def has_unparsable_json_param?
      params
      false
    rescue UnparsableJsonParam => exception
      @json_parse_error = exception
      true
    end

    # @return [true, false] True if --help or -h given
    def has_help?
      options[:help]
    end

    # @return [true, false] True if given arguments include action name
    def has_action_name?
      !!action_name
    end

    # @return [true, false] True if given arguments include target name
    def has_target_name?
      !!target_name
    end

    # @return [true, false] True if schema file exists
    def has_schema_file?
      !!schema_file_pathname
    end

    # @return [true, false] True if no error occured in parsing schema file as JSON Schema
    def has_valid_schema_file?
      !json_schema.nil?
    end

    # @return [true, false] True if no error occured in decoding schema file
    def has_decodable_schema_file?
      !!schema
    end

    # @return [true, false] True if given JSON Schema has a link of base URL of API
    def has_base_url?
      !!base_url
    end

    # @return [true, false] True if any link for given action and target found
    def has_link?
      !!link
    end

    # @return [Hash]
    def schema
      @schema ||= begin
        case schema_file_pathname.extname
        when ".yml"
          YAML.load(schema_file_body)
        else
          JSON.parse(schema_file_body)
        end
      end
    rescue
    end

    # @return [String]
    def schema_file_body
      @schema_file_body ||= schema_file_pathname.read
    end

    # @return [Pathname, nil] Found schema file path
    def schema_file_pathname
      @schema_file_pathname ||= Pathname.glob(SCHEMA_FILE_PATH_PATTERN).first
    end

    # @return [String]
    # @example
    #   path #=> "/users"
    def path
      path_with_template % path_params.symbolize_keys
    end

    # @return [String]
    # @example
    #   path_with_template #=> "/apps/%{id}"
    def path_with_template
      link.href.gsub(/{(.+?)}/) do |matched|
        key = CGI.unescape($1).gsub(/[()]/, "").split("/").last
        "%{#{key}}"
      end
    end

    # @return [Array<String>] Parameter names required for path
    # @exmaple
    #   path_keys #=> ["id"]
    def path_keys
      link.href.scan(/{(.+?)}/).map do |gr|
        CGI.unescape(gr.first).gsub(/[()]/, "").split("/").last
      end
    end

    # @return [Hash] Params to be embedded into path
    # @example
    #   path_params #=> { "id" => 1 }
    def path_params
      params.slice(*path_keys)
    end

    # @return [Hash] Params to be used for request body or query string
    # @example
    #   request_params #=> { "name" => "example" }
    def request_params
      params.except(*path_keys)
    end

    # @return [String]
    # @example
    #   method #=> "GET"
    def method
      link.method.to_s.upcase
    end

    # @return [String, nil] Base URL of the API
    # @example
    #   base_url #=> "http://localhost:8080"
    def base_url
      @base_url ||= begin
        if url = (options[:host] || base_url_from_schema)
          if url.start_with?("http")
            url
          else
            "http://#{url}"
          end
        end
      end
    end

    # Extracts the base url of the API from JSON Schema
    # @return [String, nil]
    # @example
    #   base_url_from_schema #=> "https://api.example.com/"
    def base_url_from_schema
      json_schema.links.find do |link|
        if link.href && link.rel == "self"
          return link.href
        end
      end
    end

    # @return [JsonSchema::Schema::Link, nil]
    def link
      @link ||= json_schema.properties.find do |key, schema|
        if key == target_name
          schema.links.find do |link|
            if link.href && link.method && link.title.underscore == action_name
              return link
            end
          end
        end
      end
    end

    # @return [JsonSchema::Schema, nil]
    def json_schema
      @json_schema ||= JsonSchema.parse!(@schema).tap(&:expand_references!)
    rescue => exception
      @json_schema_error = exception
      nil
    end

    # @return [Plz::Arguments] Wrapper of Raw ARGV
    def arguments
      @arguments ||= Arguments.new(@argv)
    end

    # @return [Hash] Command line options
    def options
      @options ||= Slop.parse!(@argv) do
        banner Error::USAGE
        on "h", "help", "Display help message"
        on "H", "host=", "API host"
        on "no-color", "Disable coloring output"
        on "no-response-body", "Hide response body"
        on "no-response-header", "Hide response header"
      end
    end
  end
end
