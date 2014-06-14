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
          schema.links.select do |link|
            link.href && link.method && link.title
          end.map do |link|
            str = "  plz #{link.title.underscore} #{target_name.underscore}"
            if key = link.href[/{(.+)}/, 1]
              name = CGI.unescape(key).gsub(/[()]/, "").split("/").last
              if property = link.parent.properties[name]
                if example = property.data["example"]
                  str << " #{name}=#{example.inspect}"
                end
              end
            end
            str
          end
        end.flatten
      end
    end
  end
end
