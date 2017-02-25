require_relative 'client_request'

module Proton
  class Net
    class << self
      def request(options)
        client = Proton::ClientRequest.new(options)
        if block_given?
          yield client
        end
        client
      end
    end
  end
end
