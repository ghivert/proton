module Proton
  class Remote
    @remote = `electron.remote`
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
  end
end
