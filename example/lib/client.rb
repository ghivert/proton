require 'node/net'
require_relative 'shared'
require_relative 'processing'

class Client
  class << self
    def connect
      begin
        $values.client = Node::Net.connect({ port: 2016 })
        $values.client.write("CONNEXION/#{$values.user}/\n")
        $values.client.on_data do |data|
          process_data data
        end
      rescue Exception => err
        raise err
      end
    rescue Exception => err
      raise err
    end

    def unconnect
      $values.client.write("SORT/#{$values.user}/\n")
      $values.client.finish
    end
  end
end
