module Plz
  module Commands
    class NoActionName
      def call
        puts "You didn't pass action name\n#{Error::USAGE}"
      end
    end
  end
end
