require 'opal'
require_relative 'proton_app'
require_relative 'proton_global'
require_relative 'proton_process'

module Proton
  def self.app
    Proton::App.new
  end
end
