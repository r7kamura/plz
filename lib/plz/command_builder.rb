module Plz
  class CommandBuilder
    # Builds callable command object from given ARGV
    # @return [Plz::Command]
    def self.call(arguments)
      new(arguments).call
    end

    # @param [Array<String>] ARGV
    def initialize(arguments)
      @arguments = arguments
    end

    # @return [Plz::Command]
    def call
      validate!
      Command.new
    rescue Error => error
      ErrorCommand.new(error)
    end

    private

    # @raise [Plz::Error] Raises if invalid arguments given
    def validate!
      case
      when !has_action_name?
        raise NoActionName
      when !has_target_name?
        raise NoTargetName
      end
    end

    # @return [true, false] True if given arguments include action name
    def has_action_name?
      !!action_name
    end

    # @return [true, false] True if given arguments include target name
    def has_target_name?
      !!target_name
    end

    # @return [String, nil] Given action name
    def action_name
      ARGV[0]
    end

    # @return [String, nil] Given target name
    def target_name
      ARGV[1]
    end

    class Error < Error
    end

    class NoActionName < Error
      def to_s
        "You didn't pass action name"
      end
    end

    class NoTargetName < Error
      def to_s
        "You didn't pass target name"
      end
    end
  end
end
