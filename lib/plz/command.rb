module Plz
  class Command
    # @param action_name [String]
    # @param target_name [String]
    # @param headers [Hash]
    # @param params [Hash]
    def initialize(action_name: nil, target_name: nil, headers: nil, params: nil)
      @action_name = action_name
      @target_name = target_name
      @headers = headers
      @params = params
    end

    # TODO
    # Sends an HTTP request and logs out the response
    def call
      puts "#{@action_name} #{@target_name}"
    end
  end
end
