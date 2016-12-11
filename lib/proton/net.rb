require_relative 'client_request'

module Proton
  class Net
    class << self
      def request(options)
        Proton::ClientRequest.new(options)
      end
    end
  end
end
