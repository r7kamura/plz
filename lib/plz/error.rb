module Plz
  class Error < StandardError
    USAGE = "Usage: plz <action> <target> [headers|params] [options]"
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

  class UnparsableJsonParam < Error
    def initialize(value: nil)
      @value = value
    end

    def to_s
      "Given `#{@value}` was not valid as JSON"
    end
  end

  class InvalidSchema < Error
    def initialize(pathname: nil)
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
