require 'proton/net'
require_relative 'shared'
require_relative 'processing'

def response___test(resp)
  puts "je suis la #{resp}"
end

def response___test2(resp, resp2)
  puts "je suis la #{resp}, #{resp2}"
end

def response___test3
  puts "je suis la"
end

class Client
  class << self
    def connect
      begin
        $values.client = Proton::Net.request("https://github.com") do |req|
          begin
            req.on('data') do |val|
              puts "#{val}"
            end
            req.on('response') do |val|
              puts "#{val}"
            end
            req.on('login') do |val, val2|
             puts "#{val}, #{val2}"
            end
            req.on('finish') do
              puts "nothing"
            end
            req.on('abort') do
              puts "nothing"
            end
            req.on('error') do
              puts "nothing"
            end
            req.on('close') do
              puts "nothing"
            end
            # req.write("CONNEXION/#{$values.user}/\n")
          rescue Exception => err
            raise err
          end
        end
      rescue Exception => err
        raise err
      end
    end

    def unconnect
      $values.client.write("SORT/#{$values.user}/\n")
      $values.client.finish
    end
  end
end
