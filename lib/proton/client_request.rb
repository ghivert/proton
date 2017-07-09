require 'native'

module Proton
  class ClientRequest
    def initialize(options)
      @client_request = `net.request(#{options.to_n})`
    end

    def on(event, &callback)
      `#{@client_request}.on(#{event}, #{callback.to_n})`
    end

    # Instance Properties.

    def chunked_encoding
      `#{@client_request}.chunkedEncoding`
    end

    def chunked_encoding=(obj)
      `#{@client_request}.chunkedEncoding = #{obj}`
    end

    # Instance Methods.

    def set_header(name, value)
      `#{@client_request}.setHeader(#{name}, #{value})`
    end

    def get_header(name)
      `#{@client_request}.getHeader(#{name})`
    end

    def remove_header(name)
      `#{@client_request}.removeHeader(#{name})`
    end

    def write(chunk, encoding = 'utf-8', &callback)
      if callback.nil?
        `#{@client_request}.write(#{chunk}, #{encoding})`
      else
        `#{@client_request}.write(#{chunk}, #{encoding}, #{callback})`
      end
    end

    def finish(chunk = nil, encoding = 'utf-8', &callback)
      if chunk
        `#{@client_request}.end()`
      else
        if callback.nil?
          `#{@client_request}.end(#{chunk}, #{encoding})`
        else
          `#{@client_request}.end(#{chunk}, #{encoding}, #{callback})`
        end
      end
    end

    def abort
      `#{@client_request}.abort()`
    end
  end
end
