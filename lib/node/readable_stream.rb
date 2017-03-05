module Node
  module ReadableStream
    # Events

    def on_close
      close_ = -> () { yield }
      `#{stream}.on('close', #{close_})`
    end

    def on_data
      apply_to_chunk = -> (chunk) { yield Node::Buffer.new(chunk) }
      `#{stream}.on('data', #{apply_to_chunk})`
    end

    def on_end
    end_ = -> () { yield }
    `#{stream}.on('end', #{end_})`
    end

    def on_error
      apply_to_error = -> (error) { yield error }
      `#{stream}.on('error', #{apply_to_error})`
    end
  end
end
