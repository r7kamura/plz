module Plz
  module Commands
    class Help
      # @param options [Slop]
      # @param schema [JsonSchema::Schema]
      def initialize(options: nil, schema: nil)
        @options = options
        @schema = schema
      end

      # Logs out help message
      def call
        puts %<#{@options}\nExamples:\n#{links.join("\n")}>
      end

      private

      # @return [Array<String>]
      def links
        @schema.properties.map do |target_name, schema|
          schema.links.map do |link|
            if link.href && link.method && link.title
              "  plz #{link.title.underscore} #{target_name.underscore}"
            end
          end.compact
        end.flatten
      end
    end
  end
end
