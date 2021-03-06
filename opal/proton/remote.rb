require 'proton/web_contents'

module Proton
  class Remote
    @remote = `electron.remote`
    # Class Methods

    def self.access(global_value)
      access = []
        if global_value[0] == '$'
          access << :gvars
          global_value = global_value.delete '$'
          access << global_value.to_sym
        else
          values = global_value.split('.')
          values.each { |val| access << val.to_sym }
        end
      opal = `#{@remote}.require("./main.js").Opal`
      access.each { |name| opal = opal.JS[name]}
      opal
    end

    def self.get_current_web_contents
      WebContents.new `#{@remote}.getCurrentWebContents`
    end

    def self.ready!
      `#{@remote}.getGlobal("ready").ready = true`
    end
  end
end
