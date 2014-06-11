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
    end

    class NoActionName < Error
      def to_s
        "You didn't pass action name"
      end
    end

    class NoTargetName < Error
      def to_s
        "You didn't pass target name"
      end
    end

    class SchemaFileNotFound < Error
      def to_s
        "Schema file was not found in #{SCHEMA_FILE_PATH_PATTERN}"
      end
    end
  end
end
