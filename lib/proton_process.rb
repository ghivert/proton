class Process
  class << self
    def on(event, &callback)
      `process.on(#{event}, #{callback})`
    end

    def platform
      `process.platform`
    end
  end
end
