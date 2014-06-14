module Plz
  module Commands
    class InvalidJsonFromStdin
      def call
        puts "Invalid JSON was given from STDIN"
      end
    end
  end
end
