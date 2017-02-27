require 'proton/client_request'

module Proton
  class Net
    class << self
      # Class Methods
      
      def request(options)
        Proton::ClientRequest.new(options)
      end
    end
  end
end
