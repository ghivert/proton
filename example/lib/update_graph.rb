require 'opal'
require 'proton/ipc_renderer'
require 'proton/remote'

class UpdateGraph
  @board = `document.getElementById("board")`

  def self.init
    init_ = -> () do
      robots = {}
      robots[:target] = `#{@board}.getElementById("target")`
      robots[:red]    = `#{@board}.getElementById("robot-red")`
      robots[:blue]   = `#{@board}.getElementById("robot-blue")`
      robots[:yellow] = `#{@board}.getElementById("robot-yellow")`
      robots[:green]  = `#{@board}.getElementById("robot-green")`
      robots[:black]  = `#{@board}.getElementById("robot-black")`

      update_walls
      update_graphics(robots)
      Proton::Remote.ready!
    end

    `#{@board}.addEventListener("load", #{init_}, false)`
  end

  def self.update_graphics(robots)
    Proton::IpcRenderer.on 'update-graphics' do |event, message|
      `console.log('la')`
      `#{robots[:red]}.setAttributeNS(null, "visibility", "visible")`
      `#{robots[:blue]}.setAttributeNS(null, "visibility", "visible")`
      `#{robots[:yellow]}.setAttributeNS(null, "visibility", "visible")`
      `#{robots[:green]}.setAttributeNS(null, "visibility", "visible")`
      `#{robots[:target]}.setAttributeNS(null, "visibility", "visible")`

      `#{robots[:red]}.setAttributeNS(null, "cx",    (#{message[0]} - 1) * 40 + 17.5)`
      `#{robots[:red]}.setAttributeNS(null, "cy",    (#{message[1]} - 1) * 40 + 17.5)`
      `#{robots[:blue]}.setAttributeNS(null, "cx",   (#{message[2]} - 1) * 40 + 17.5)`
      `#{robots[:blue]}.setAttributeNS(null, "cy",   (#{message[3]} - 1) * 40 + 17.5)`
      `#{robots[:yellow]}.setAttributeNS(null, "cx", (#{message[4]} - 1) * 40 + 17.5)`
      `#{robots[:yellow]}.setAttributeNS(null, "cy", (#{message[5]} - 1) * 40 + 17.5)`
      `#{robots[:green]}.setAttributeNS(null, "cx",  (#{message[6]} - 1) * 40 + 17.5)`
      `#{robots[:green]}.setAttributeNS(null, "cy",  (#{message[7]} - 1) * 40 + 17.5)`
      `#{robots[:target]}.setAttributeNS(null, "x",  (#{message[8]} - 1) * 40)`
      `#{robots[:target]}.setAttributeNS(null, "y",  (#{message[9]} - 1) * 40)`

      case message[10]
      when 'B' then `#{robots[:target]}.setAttributeNS(null, "fill", "blue")`
      when 'R' then `#{robots[:target]}.setAttributeNS(null, "fill", "red")`
      when 'V' then `#{robots[:target]}.setAttributeNS(null, "fill", "green")`
      when 'J' then `#{robots[:target]}.setAttributeNS(null, "fill", "yellow")`
      end
    end
  end

  def self.update_walls
    Proton::IpcRenderer.on 'update-walls' do |event, message|
      line = `document.createElementNS('http://www.w3.org/2000/svg', 'line')`
      `#{line}.setAttribute('x1', #{message[0]})`
      `#{line}.setAttribute('y1', #{message[1]})`
      `#{line}.setAttribute('x2', #{message[2]})`
      `#{line}.setAttribute('y2', #{message[3]})`
      `#{line}.setAttribute('stroke', 'rgb(0,0,0)')`
      `#{line}.setAttribute('stroke-width', 10)`
      `#{@board}.appendChild(#{line})`
    end
  end
end

UpdateGraph.init
