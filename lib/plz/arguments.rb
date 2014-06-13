module Plz
  class Arguments
    # @param arguments [Array] Raw ARGV
    def initialize(argv)
      @argv = argv
    end

    # @return [String, nil] Given action name
    def action_name
      ARGV[0]
    end

    # @return [String, nil] Given target name
    def target_name
      ARGV[1]
    end

    # @return [Hash] Params parsed from given arguments
    # @raise [Plz::UnparsableJsonParam]
    def params
      ARGV[2..-1].inject({}) do |result, section|
        case
        when /(?<key>.+):=(?<value>.+)/ =~ section
          begin
            result.merge(key => JSON.parse(%<{"key":#{value}}>)["key"])
          rescue JSON::ParserError
            raise UnparsableJsonParam, key: key, value: value
          end
        when /(?<key>.+)=(?<value>.+)/ =~ section
          result.merge(key => value)
        else
          result
        end
      end
    end

    # @return [Hash] Headers parsed from given arguments
    def headers
      ARGV[2..-1].inject({}) do |result, section|
        case
        when /(?<key>.+):(?<value>[^=]+)/ =~ section
          result.merge(key => value)
        else
          result
        end
      end
    end
  end
end
