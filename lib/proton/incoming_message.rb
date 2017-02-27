require 'node/buffer'
require 'node/readable_stream'

module Proton
  class IncomingMessage
    attr_reader :incoming_message
    alias_method :incoming_message, :stream
    include Node::ReadableStream

    def initialize(incoming_message)
      @incoming_message = incoming_message
    end

    # Events

    def on_aborted
      `#{incoming_message}.on('aborted', #{yield})`
    end

    # Instance Properties

    def status_code
      `#{incoming_message}.statusCode`
    end

    def status_message
      `#{incoming_message}.statusMessage`
    end

    def headers
      `#{incoming_message}.headers`
    end

    def http_version
      `#{incoming_message}.httpVersion`
    end

    def http_version_major
      `#{incoming_message}.httpVersionMajor`
    end

    def http_version_minor
      `#{incoming_message}.httpVersionMinor`
    end
  end
end
