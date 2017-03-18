module Node
  class Buffer
    attr_reader :buffer

    def initialize(buffer)
      @buffer = buffer
    end

    def to_s
      `#{buffer}.toString()`
    end
  end
end
