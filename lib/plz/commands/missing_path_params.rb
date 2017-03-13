module Plz
  module Commands
    class MissingPathParams
      def initialize(action_name: nil, target_name: nil, params: [])
        @action_name = action_name
        @target_name = target_name
        @params = params
      end

      def call
        puts %<`#{@action_name} #{@target_name}` requires these params: #{@params.join(" ")}>
      end
    end
  end
end
