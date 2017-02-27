module Node
  module ReadableStream
    # Events

    def on_close
      `#{stream}.on('close', #{yield})`
    end

    def on_data
      apply_to_chunk = -> (chunk) {
        yield Node::Buffer.new(chunk)
      }
      `#{stream}.on('data', #{apply_to_chunk})`
    end

    def on_end
      `#{stream}.on('end', #{yield})`
    end

    def on_error
      apply_to_error = -> (error) {
        yield error
      }
      `#{stream}.on('error', #{apply_to_error})`
    end
  end
end
