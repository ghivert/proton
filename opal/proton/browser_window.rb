require 'native'
require 'proton/web_contents'

module Proton
  class BrowserWindow
    def initialize(options)
      @window = `new BrowserWindow(#{options.to_n})`
      @web_contents = WebContents.new(`#{@window}.webContents`)
    end

    # Instance Properties

    def web_contents
      @web_contents
    end

    # Events

    def on(event, &callback)
      `#{@window}.on(#{event}, #{callback})`
    end

    # Instance Methods

    def load_url(url)
      `#{@window}.loadURL(#{url})`
    end

    def close
      `#{@window}.close()`
    end

    def toggle_dev_tools
      `#{@window}.toggleDevTools()`
    end
  end
end
