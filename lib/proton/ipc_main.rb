module Proton
  class IpcMain
    @ipc = `electron.ipcMain`
    class << self
      # Events

      def on(channel, &callback)
        `#{@ipc}.on(#{channel}, #{callback})`
      end

      def once(channel, &callback)
        `#{@ipc}.once(#{channel}, #{callback})`
      end

      def remove_listener(channel, &callback)
        `#{@ipc}.removeListener(#{channel}, #{callback})`
      end

      def remove_all_listeners(*channels)
        `#{@ipc}.removeAllListeners(#{channel})`
      end
    end
  end
end
