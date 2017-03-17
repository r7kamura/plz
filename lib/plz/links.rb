module Plz
  class Links
    # @param schema [JsonSchema::Schema]
    def initialize(schema)
      @schema = schema
    end

    # @param link [JsonSchema::Schema::Link]
    # @return [true, false] True if the link has all the attributes we need
    def link_valid?(link)
      link.href && link.method && link.title
    end

    # @return [Array<JsonSchema::Schema::Link>] List of all valid links in the schema
    def all_links
      @schema.properties.map do |target, subschema|
        [
          target,
          subschema.links.select do |link|
            link_valid?(link)
          end
        ]
      end
    end

    # @param target [String] Target name
    # @return [Array<JsonSchema::Schema::Link>, nil] List of all valid links for a target
    def target_links(target)
      @schema.properties.has_key?(target) &&
        @schema.properties[target].links.select do |link|
          link_valid?(link)
        end || nil
    end

    # @param action [String] Action name
    # @param target [String] Target name
    # @return [JsonSchema::Schema::Link, nil] Link for an action on a target
    def action_link(action, target)
      if (links = target_links(target))
        links.find do |link|
          link.title.underscore == action
        end
      end
    end
  end
end
