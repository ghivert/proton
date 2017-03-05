require 'opal'
require 'proton/ipc_renderer'
require 'proton/remote'

$values = Proton::Remote.access('$values')
class Event
  def self.update_name
    name = `document.getElementById("nameConnect")`
    $values.user = name.JS[:value]
    Proton::IpcRenderer.send 'name'
  end

  def self.enter_name(event)
    if (event.JS[:keyCode] == 13)
      update_name
    end
  end
end
