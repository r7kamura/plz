module Plz
  module Commands
    class NoTargetName
      def call
        puts "You didn't pass target name\n#{Error::USAGE}"
      end
    end
  end
end
