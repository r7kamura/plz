module Plz
  class Error < StandardError
    USAGE = "Usage: plz <action> <target> [headers|params] [options]"
  end

  class UnparsableJsonParam < Error
    attr_reader :value

    def initialize(value: nil)
      @value = value
    end
  end
end
