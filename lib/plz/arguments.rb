module Plz
  class Arguments
    # @param arguments [Array] Raw ARGV
    def initialize(argv)
      @argv = argv
    end

    # @return [String, nil] Given action name
    def action_name
      @argv[0]
    end

    # @return [String, nil] Given target name
    def target_name
      @argv[1]
    end

    # @return [Hash] Params parsed from given arguments & STDIN
    # @raise [Plz::UnparsableJsonParam]
    def params
      params_from_stdin.merge(params_from_argv)
    end

    # @return [Hash] Headers parsed from given arguments
    def headers
      @argv[2..-1].each_with_object({}) do |section, result|
        case
        when /(?<key>.+)(?<!=):(?!=)(?<value>.+)/ =~ section
          result[key] = value
        end
      end
    end

    # @return [true, false] true if invalid JSON input is given via STDIN
    def has_invalid_json_input?
      params_from_stdin
      false
    rescue JSON::ParserError
      true
    end

    private

    # @return [Hash] Params extracted from STDIN
    def params_from_stdin
      @params_from_stdin ||= begin
        if has_input_from_stdin?
          JSON.parse(STDIN.read)
        else
          {}
        end
      end
    end

    # @return [Hash] Params extracted from ARGV
    def params_from_argv
      @params_from_argv ||= @argv[2..-1].each_with_index.with_object({}) do |(section, i), result|
        case
        when /(?<key>.+):=(?<value>.+)/ =~ section
          begin
            result[key] = JSON.parse(%<{"key":#{value}}>)["key"]
          rescue JSON::ParserError
            raise UnparsableJsonParam, value: value
          end
        when /(?<key>.+)=:(?<value>.+)/ =~ section
          result[key] = value
        when /(?<key>.+)=(?<value>.+)/ =~ section
          begin
            result[key] = JSON.parse(%<{"key":#{value}}>)["key"]
          rescue JSON::ParserError
            result[key] = value
          end
        when i.zero? && section !~ /:/
          # special case for the first argument - treat it like "target=argument"
          key = target_name
          value = section
          begin
            result[key] = JSON.parse(%<{"key":#{value}}>)["key"]
          rescue JSON::ParserError
            result[key] = value
          end
        end
      end
    end

    # @return [true, false] True if any input given via STDIN
    def has_input_from_stdin?
      has_pipe_input? || has_redirect_input?
    end

    # @return [true, false] True if any input given from redirection
    def has_redirect_input?
      File.select([STDIN], [], [], 0) != nil
    end

    # @return [true, false] True if any input given from pipe
    def has_pipe_input?
      File.pipe?(STDIN)
    end
  end
end
