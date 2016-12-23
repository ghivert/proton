require 'native'

module Proton
  class BrowserWindow
    class WebContents
      # Class functions
      class << self
        def get_all_web_contents
          arr, wcs = [], `webContents.getAllWebContents()`
          (0...`wcs.length`).each do |i|
            arr << WebContents.new(wcs.JS[i])
          end
          arr
        end

        def get_focused_web_contents
          wc = `webContents.getFocusedWebContents()`
          if wc
            WebContents.new(wc)
          else
            nil
          end
        end

        def from_id(id)
          wc = `webContents.fromId(id)`
          if wc
            WebContents.new(wc)
          else
            nil
          end
        end
      end

      # Instance functions.
      def initialize(content)
        @content = content
      end

      def send(chan, *rest)
        if rest.size == 0
          `#{@content}.send(#{chan})`
        else
          rest.each { |var| `#{@content}.send(#{chan}, #{var})` }
        end
      end

      # Refactor for better code.
      def id
        `#{@content}.id`
      end

      def session
        `#{@content}.session`
      end

      def host_web_contents
        `#{@content}.hostWebContents`
      end

      def dev_tools_web_contents
        `#{@content}.devToolsWebContents`
      end

      def debugger
        `#{@content}.debugger`
      end
    end
  end
end
