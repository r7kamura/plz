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
        prog_name = File.basename($0)
        @schema.properties.map do |target_name, schema|
          schema.links.select do |link|
            link.href && link.method && link.title
          end.map do |link|
            str = "  #{prog_name} #{link.title.underscore} #{target_name}"
            link.href.scan(/{(.+?)}/).each do |gr|
              path = CGI.unescape(gr.first).gsub(/[()]/, "")
              name = path.split("/").last
              if property = JsonPointer.evaluate(@schema, path)
                example = property.data.fetch("example", "<>")
                str << " #{name}=#{example}"
              end
            end
            str
          end
        end.flatten
      end
    end
  end
end
