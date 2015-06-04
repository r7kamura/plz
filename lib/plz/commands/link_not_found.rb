module Plz
  module Commands
    class LinkNotFound
      def initialize(pathname: nil, action_name: nil, target_name: nil)
        @pathname = pathname
        @action_name = action_name
        @target_name = target_name
      end

      def call
        puts "#{@pathname} has no definition for `#{@action_name} #{@target_name}`"
      end
    end
  end
end
