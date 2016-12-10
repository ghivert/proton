require 'proton/net'
require_relative 'shared'
require_relative 'processing'

class Client
  class << self
    def connect
      begin
        @values.client = Proton::Net.connect({ port: 2016 }) do
          begin
            @values.client.write("CONNEXION/#{@values.user}/\n")
          rescue Exception => err
            raise err
          end
        end
      rescue Exception => err
        raise err
      end

      begin
        @values.client.on('data', process_data)
      rescue Exception => err
        puts  err
        raise err
      end
    end

    def unconnect
      @values.client.write("SORT/#{@values.user}/\n")
      @values.client.end
    end
  end
end
