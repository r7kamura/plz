module Plz
  class CommandBuilder
    SCHEMA_FILE_PATH_PATTERN = "{.,config}/schema.{json,yml}"

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
        action_name: action_name,
        target_name: target_name,
        headers: headers,
        params: params,
        schema: schema,
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
      when !has_valid_schema_file?
        raise InvalidSchemaFile, schema_file_pathname
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

    # @return [true, false] True if no error occured in parsing schema file
    def has_valid_schema_file?
      !!schema
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

    class Error < Error
      USAGE = <<-EOS.strip_heredoc
        $ plz <action> <target> [headers|params]
                  |        |         |      |
                  |        |         |      `---- key=value ({"key":"value"}) or key:=value ({"key":value})
                  |        |         |            params can be:
                  |        |         |            * URI Template variable
                  |        |         |            * Query string in GET method
                  |        |         |            * Request body in other methods
                  |        |         |
                  |        |         `----------- Key:value
                  |        |
                  |        `--------------------- target resource name (e.g. user, recipe, etc.)
                  |
                  `------------------------------ action name (e.g. show, list, create, delete, etc.)
      EOS
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

    class InvalidSchemaFile < Error
      def initialize(pathname)
        @pathname = pathname
      end

      def to_s
        "Failed to parse #{@pathname}"
      end
    end
  end
end
