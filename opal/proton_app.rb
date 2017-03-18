module Proton
  class App
    def initialize
      @app = `electron.app`
    end

    def on(event, &callback)
      `#{@app}.on(#{event}, #{callback})`
    end

    def quit
      `#{@app}.quit()`
    end
  end
end
