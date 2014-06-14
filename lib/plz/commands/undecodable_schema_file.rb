module Plz
  module Commands
    class UndecodableSchemaFile
      def initialize(pathname: nil)
        @pathname = pathname
      end

      def call
        puts "Failed to decode #{@pathname}"
      end
    end
  end
end
