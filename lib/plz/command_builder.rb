module Plz
  class CommandBuilder
    # Builds callable command object from given ARGV
    # @return [Plz::Command]
    def self.call(arguments)
      new(arguments).call
    end

    # @param [Array<String>] ARGV
    def initialize(arguments)
      @arguments = arguments
    end

    # @return [Plz::Command]
    def call
      Command.new
    end
  end
end
