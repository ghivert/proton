module Node
  module WritableStream
    # Events
    
    def on_close
      `#{stream}.on('close', #{yield})`
    end

    def on_drain
      `#{stream}.on('drain', #{yield})`
    end

    def on_error
      apply_to_error = -> (error) {
        yield error
      }
      `#{stream}.on('error', #{apply_to_error})`
    end

    def on_finish
      `#{stream}.on('finish', #{yield})`
    end

    # Instance Methods

    def write(data, encoding = 'utf-8', &callback)
      if callback.nil?
        `#{stream}.write(#{data}, #{encoding})`
      else
        `#{stream}.write(#{data}, #{encoding}, #{callback})`
      end
    end

    def finish(chunk = nil, encoding = 'utf-8', &callback)
      if chunk.nil?
        if callback.nil?
          `#{stream}.end()`
        else
          `#{stream}.end(#{callback})`
        end
      else
        if callback.nil?
          `#{stream}.end(#{chunk}, #{encoding})`
        else
          `#{stream}.end(#{chunk}, #{encoding}, #{callback})`
        end
      end
    end
  end
end
