require 'native'
require_relative 'web_contents'

module Proton
  class BrowserWindow
    def initialize(options)
      @window = `new BrowserWindow(#{options.to_n})`
      @web_contents = WebContents.new(`#{@window}.webContents`)
    end

    def load_url(url)
      `#{@window}.loadURL(#{url})`
    end

    def on(event, &callback)
      `#{@window}.on(#{event}, #{callback})`
    end

    def web_contents
      @web_contents
    end

    def close
      `#{@window}.close()`
    end

    def toggle_dev_tools
      `#{@window}.toggleDevTools()`
    end
  end
end
