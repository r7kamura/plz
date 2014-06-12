module Plz
  class CommandBuilder
    SCHEMA_FILE_PATH_PATTERN = "schema.{json,yml}"

    # Builds callable command object from given ARGV
    # @return [Plz::Command]
    # @example
    #   Plz::CommandBuilder.call(ARGV).call
    def self.call(arguments)
      new(arguments).call
    end

    # @param [Array<String>] ARGV
    def initialize(arguments)
      @arguments = arguments
    end

    # @return [Plz::Command] Callable command object
    def call
      validate!
      Command.new(
        method: method,
        base_url: base_url,
        path: path,
        headers: headers,
        params: params,
      )
    rescue Error => error
      ErrorCommand.new(error)
    end

    private

    # @raise [Plz::Error] Raises if invalid arguments given
    def validate!
      case
      when !has_action_name?
        raise NoActionName
      when !has_target_name?
        raise NoTargetName
      when !has_schema_file?
        raise SchemaFileNotFound
      when !has_decodable_schema_file?
        raise UndecodableSchemaFile, pathname: schema_file_pathname
      when !has_valid_schema_file?
        raise InvalidSchema, pathname: schema_file_pathname
      when !has_base_url?
        raise BaseUrlNotFound, pathname: schema_file_pathname
      when !has_link?
        raise LinkNotFound, pathname: schema_file_pathname, action_name: action_name, target_name: target_name
      end
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
      !!json_schema
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

    # @return [String, nil] Given action name
    def action_name
      ARGV[0]
    end

    # @return [String, nil] Given target name
    def target_name
      ARGV[1]
    end

    # TODO
    # @return [Hash] Params made from given arguments
    def params
      {}
    end

    # TODO
    # @return [Hash] Headers made from given arguments
    def headers
    end

    # @return [String]
    # @example
    #   path #=> "/users"
    def path
      link.href
    end

    # @return [String]
    # @example
    #   method #=> "GET"
    def method
      link.method.to_s.upcase
    end

    # Extracts the base url of the API
    # @return [String, nil]
    # @example
    #   base_url #=> "https://api.example.com/"
    def base_url
      @base_url ||= json_schema.links.find do |link|
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
    rescue JsonSchema::SchemaError
    end

    class Error < Error
      USAGE = "Usage: plz <action> <target> [headers|params]"
    end

    class NoActionName < Error
      def to_s
        "You didn't pass action name\n#{USAGE}"
      end
    end

    class NoTargetName < Error
      def to_s
        "You didn't pass target name\n#{USAGE}"
      end
    end

    class SchemaFileNotFound < Error
      def to_s
        "Schema file was not found in #{SCHEMA_FILE_PATH_PATTERN}"
      end
    end

    class InvalidSchema < Error
      def initialize(pathname: pathname)
        @pathname = pathname
      end
    end

    class UndecodableSchemaFile < InvalidSchema
      def to_s
        "Failed to decode #{@pathname}"
      end
    end

    class InvalidSchemaFile < InvalidSchema
      def to_s
        "#{@pathname} was invalid JSON Schema"
      end
    end

    class BaseUrlNotFound < InvalidSchema
      def to_s
        "#{@pathname} has no base URL at top-level links property"
      end
    end

    class LinkNotFound < InvalidSchema
      def initialize(action_name: action_name, target_name: target_name, **args)
        super(**args)
        @action_name = action_name
        @target_name = target_name
      end

      def to_s
        "#{@pathname} has no definition for `#{@action_name} #{@target_name}`"
      end
    end
  end
end
