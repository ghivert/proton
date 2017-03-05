module Proton
  class IpcRenderer
    @ipc = `electron.ipcRenderer`
    class << self
      # Instance Methods

      def send(channel)
        `#{@ipc}.send(#{channel})`
      end

      def on(event, &callback)
        `#{@ipc}.on(#{event}, #{callback})`
      end
    end
  end
end
