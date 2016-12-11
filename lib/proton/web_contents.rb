require 'native'

class WebContents
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
      wc.nil? ? nil : WebContents.new(wc)
    end

    def from_id(id)
      wc = `webContents.fromId(id)`
      wc.nil? ? nil : WebContents.new(wc)
    end
  end

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
end
