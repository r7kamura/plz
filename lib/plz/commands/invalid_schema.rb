module Plz
  module Commands
    class InvalidSchema
      def initialize(filename: nil, error: nil)
        @filename = filename
        @error = error
      end

      def call
        puts "#{@filename} was invalid:#{error_message}"
      end

      private

      def error_message
        @error.to_s.gsub("#: ", "\n")
      end
    end
  end
end
