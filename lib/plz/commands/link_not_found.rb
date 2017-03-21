module Plz
  module Commands
    class LinkNotFound
      def initialize(filename: nil, action_name: nil, target_name: nil)
        @filename = filename
        @action_name = action_name
        @target_name = target_name
      end

      def call
        puts "#{@filename} has no definition for `#{@action_name} #{@target_name}`"
      end
    end
  end
end
