module Plz
  module Commands
    class InvalidSchema
      def initialize(pathname: nil, error: error)
        @pathname = pathname
        @error = error
      end

      def call
        puts "#{@pathname} was invalid:#{error_message}"
      end

      private

      def error_message
        @error.to_s.gsub("#: ", "\n")
      end
    end
  end
end
