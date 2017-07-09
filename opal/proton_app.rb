module Proton
  class App
    def initialize
      @app = `electron.app`
    end

    def on(event, &callback)
      `#{@app}.on(#{event}, #{callback})`
    end

    def on_window_all_closed
      closed_ = -> () { yield }
      `#{@app}.on('window-all-closed', #{closed_})`
    end

    def on_ready
      ready_ = -> (launch_info) { yield launch_info }
      `#{@app}.on('ready', #{ready_})`
    end

    def quit
      `#{@app}.quit()`
    end
  end
end
