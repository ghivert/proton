require 'native'
require 'proton/web_contents'

class FromWindowAssignementError < Exception
end


module Proton
  class BrowserWindow
    class << self
      def from_window(window)
        if window.is_a? Proton::BrowserWindow
          alloc(window.to_js)
        else
          raise FromWindowAssignementError
        end
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
      @web_contents = WebContents.new(`#{@window}.webContents`)
    end

    # Instance Properties

    def web_contents
      @web_contents
    end

    # Events

    def on_closed
      closed_ = -> (event) { yield event }
      `#{@window}.on('closed', #{closed_})`
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

    def to_js
      @window
    end
  end
end
