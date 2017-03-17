module Plz
  module Commands
    class Help
      MAX_EXAMPLES = 20

      # @param options [Slop]
      # @param schema [JsonSchema::Schema]
      # @param action [String] Action name, if any
      # @param target [String] Target name, if any
      def initialize(options: nil, schema: nil, action: nil, target: nil)
        @options = options
        @schema = schema
        @links = Links.new(schema)
        @action = action
        @target = target
      end

      # Logs out help message
      def call
        puts @options
        if (link = @links.action_link(@action, @target)) && !@options[:'help-all']
          puts %<Example:\n  #{example(@target, link)}>
        elsif (links = @links.target_links(@target)) && !links.empty?
          puts "Examples:"
          links.each do |link|
            puts %<  #{example(@target, link)}>
          end
        else
          all_links = @links.all_links
          all_links_count = all_links.inject(0) do |n, (target, links)|
            n + links.length
          end
          if all_links_count <= MAX_EXAMPLES ||
              @options[:'help-all'] ||
              @action == "help" && @target == "all"
            puts %<Examples:\n  #{examples.join("\n  ")}>
          else
            puts "Selected examples:\n(`help all` displays all #{all_links_count} examples; `help <target>` displays all examples for the target)"
            all_links.each do |target, links|
              puts %<  #{example(target, links.sample)}>
            end
          end
        end

        if @target && @target != "all"
          puts %<\nProperties for target `#{@target}`:\n  #{Array(describe_properties(@target)).join("\n  ")}>
        end
      end

      private

      # @return [Array<String>]
      def examples
        @links.all_links.flat_map do |target, links|
          links.map do |link|
            example(target, link)
          end
        end
      end

      # @param target [String]
      # @param link [JsonSchema::Schema::Link]
      # @return [String]
      def example(target, link)
        str = "#{prog_name} #{link.title.underscore} #{target}"
        link.href.scan(/{(.+?)}/).each_with_index do |gr, i|
          path = CGI.unescape(gr.first).gsub(/[()]/, "")
          name = path.split("/").last
          if property = JsonPointer.evaluate(@schema, path)
            example = property.data.fetch("example", "<>")
            if i.zero? && name == target
              str << " [#{name}=]#{example}"
            else
              str << " #{name}=#{example}"
            end
          end
        end
        str
      end

      # @return [String]
      def prog_name
        @prog_name ||= File.basename($0)
      end

      # @param target [String]
      # @return [Array<String>,nil]
      def describe_properties(target)
        if (target_schema = @schema.properties[@target])
          target_schema.properties.map do |name, prop_schema|
            info = case
                   when prop_schema.read_only?
                     next
                   when prop_schema.data.has_key?("example")
                     example = prop_schema.data['example']
                     while example.is_a?(Hash) && example['$ref'] =~ %r<^#/>
                       example = JsonPointer.evaluate(@schema.data, example['$ref'])
                     end
                     if example
                       "e.g. #{example.inspect}"
                     end
                   when !prop_schema.type.empty?
                     prop_schema.type.map(&:capitalize).join("|")
                   end
            descr = [info, prop_schema.description].compact.join(" - ")
            descr = "sorry, no help here :-(" if descr.empty?
            required = target_schema.required.include?(name) ? "REQUIRED" : "optional"
            "(#{required}) #{name} : #{descr}"
          end.compact
        end
      end
    end
  end
end
