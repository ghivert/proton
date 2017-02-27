module Proton
  class IpcRenderer
    @ipc = `electron.ipcRenderer`
    class << self
      # Instance Methods

      def send(channel)
        `#{@ipc}.send(#{channel})`
      end
    end
  end
end
