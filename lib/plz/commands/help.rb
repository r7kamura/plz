module Plz
  module Commands
    class Help
      # @param options [Slop]
      def initialize(options: nil)
        @options = options
      end

      def call
        puts @options.to_s
      end
    end
  end
end
