module Plz
  class ErrorCommand
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

    # @param error [Plz::Error] Error to show error message to user
    def initialize(error)
      @error = error
    end

    # Logs out error reason and usage, then exits with error code 1
    def call
      puts "Error: #{@error}"
      puts USAGE
      exit(1)
    end
  end
end
