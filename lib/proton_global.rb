require 'native'

class Global
  class << self
    def main_window
      `global.mainWindow`
    end

    def main_window=(obj)
      `global.mainWindow = #{obj}`
    end

    def ready=(obj)
      `global.ready = #{obj.to_n}`
    end
  end
end
