module Plz
  module Commands
    class BaseUrlNotFound
      def initialize(filename: nil)
        @filename = filename
      end

      def call
        puts "#{@filename} has no base URL at top-level links property"
      end
    end
  end
end
