require 'native'
require_relative 'web_contents'

module Proton
  class BrowserWindow
    class << self
      def from_window(window)
        alloc(window)
      end

      def new(options)
        alloc(`new BrowserWindow(#{options.to_n})`)
      end

      def alloc(var)
        browser_window = self.allocate
        browser_window.initialize var
        browser_window
      end
    end

    def initialize(window)
      @window = window
    end

    def close
      `#{@window}.close()`
    end

    def load_url(url)
      puts "#{@window}"
      `#{@window}.loadURL(#{url})`
    end

    def on(event, &callback)
      `#{@window}.on(#{event}, #{callback})`
    end

    def web_contents
      WebContents.new(`#{@window}.webContents`)
    end

    def to_js
      @windows
    end
  end
end
