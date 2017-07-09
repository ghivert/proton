require 'proton/net'
require_relative 'shared'
require_relative 'processing'

class Client
  class << self
    def connect
      begin
        $values.client = Proton::Net.request({ port: 2016 })
        begin
          $values.client.write("CONNEXION/#{$values.user}/\n")
        rescue Exception => err
          raise err
        end
      rescue Exception => err
        raise err
      end

      begin
        $values.client.on('data', process_data)
        p $values.client.chunked_encoding
        p $values.client.chunked_encoding = true
        p $values.client.chunked_encoding
      rescue Exception => err
        puts  err
        raise err
      end
    end
  end

  def unconnect
    $values.client.write("SORT/#{$values.user}/\n")
    $values.client.finish
  end
end
