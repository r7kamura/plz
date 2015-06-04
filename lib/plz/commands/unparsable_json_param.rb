module Plz
  module Commands
    class UnparsableJsonParam
      def initialize(error: nil)
        @error = error
      end

      def call
        puts "Given `#{@error.value}` was not valid as JSON"
      end
    end
  end
end
