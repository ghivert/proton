require 'native'
require 'node/buffer'

module Node
  class Net
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    # Events

    def on_data
      apply_to_chunk = -> (chunk) {
        yield Node::Buffer.new(chunk)
      }
      `#{connection}.on('data', #{apply_to_chunk})`
    end

    # Instance Methods

    def write(data, encoding = 'utf-8', &callback)
      if callback.nil?
        `#{connection}.write(#{data}, #{encoding})`
      else
        `#{connection}.write(#{data}, #{encoding}, #{callback})`
      end
    end

    # Class Methods

    def self.connect(options={})
      Net.new(`nodeNet.connect(#{options.to_n})`)
    end
  end
end
