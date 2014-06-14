module Plz
  module Commands
    class BaseUrlNotFound
      def initialize(pathname: nil)
        @pathname = pathname
      end

      def call
        puts "#{@pathname} has no base URL at top-level links property"
      end
    end
  end
end
