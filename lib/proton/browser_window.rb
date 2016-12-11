require 'native'
require_relative 'web_contents'

module Proton
  class BrowserWindow
    def initialize(options)
      @window = `new BrowserWindow(#{options.to_n})`
    end

    def load_url(url)
      `#{@window}.loadURL(#{url})`
    end

    def on(event, &callback)
      `#{@window}.on(#{event}, #{callback})`
    end

    def web_contents
      WebContents.new(`#{@window}.webContents`)
    end
  end
end
