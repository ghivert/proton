require 'opal'
require 'proton_app'
require 'proton_global'
require 'proton_process'

module Proton
  def self.app
    Proton::App.new
  end
end
