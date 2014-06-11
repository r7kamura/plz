module Plz
  class ErrorCommand
    # @param error [Plz::Error] Error to show error message to user
    def initialize(error)
      @error = error
    end

    # Logs out error reason and usage, then exits with error code 1
    def call
      puts "Error: #{@error}"
      exit(1)
    end
  end
end
