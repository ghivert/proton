require 'native'

class MainWindowAssignementError < Exception
end

class Global
  class << self
    def main_window
      Proton::BrowserWindow.from_window `global.mainWindow`
    end

    def main_window=(obj)
      unless obj
        `global.mainWindow = #{obj}`
      else
        if obj.is_a? Proton::BrowserWindow
          `global.mainWindow = #{obj.to_js}`
        else
          raise MainWindowAssignementError
        end
      end
    end

    def ready=(obj)
      `global.ready = #{obj.to_n}`
    end
  end
end
