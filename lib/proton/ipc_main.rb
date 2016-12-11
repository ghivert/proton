module Proton
  class IpcMain
    @ipc = `electron.ipcMain`
    class << self
      def on(channel, &callback)
        puts callback
        `#{@ipc}.on(#{channel}, #{callback})`
        puts @ipc
        `#{@ipc}.on('name', function () {
          console.log('Yes !');
        })`
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
