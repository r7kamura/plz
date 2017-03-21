module Plz
  module Commands
    class UndecodableSchemaFile
      def initialize(filename: nil, error: nil)
        @filename = filename
        @error = error
      end

      def call
        message = "Failed to decode #{@filename}"
        message << ": #{@error}" if @error
        puts message
      end
    end
  end
end
