require 'proton/incoming_message'
require 'node/writable_stream'

module Proton
  class ClientRequest
    include WritableStream
    attr_reader :client_request
    alias_method :client_request, :stream

    def initialize(options)
      @client_request = `net.request(#{options.to_n})`
    end

    # Events

    def on_response
      apply_to_message = -> (incoming_message) do
        yield Proton::IncomingMessage.new(incoming_message)
      end
      `#{client_request}.on('response', #{apply_to_message})`
    end

    def on_login
      apply_to_auth_info = -> (auth_info, callback) do
        yield Proton::AuthInfo.new(auth_info), callback
      end
      `#{client_request}.on('login', #{apply_to_auth_info})`
    end

    def on_abort
      abort_ = -> () { yield }
      `#{client_request}.on('login', #{abort_})`
    end

    # Instance Properties

    def chunked_encoding
      `#{client_request}.chunkedEncoding`
    end

    def chunked_encoding=(obj)
      `#{client_request}.chunkedEncoding = #{obj}`
    end

    # Instance Methods

    def set_header(name, value)
      `#{client_request}.setHeader(#{name}, #{value})`
    end

    def get_header(name)
      `#{client_request}.getHeader(#{name})`
    end

    def remove_header(name)
      `#{client_request}.removeHeader(#{name})`
    end

    def abort
      `#{client_request}.abort()`
    end
  end
end
