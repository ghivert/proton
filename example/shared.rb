require 'ostruct'

class Shared
  def self.values
    OpenStruct.new(
      user:      nil,
      client:    nil,
      board:     [],
      round:     0,
      enigma:    Enigma.new,
      opponents: {},
      solution:  [],
      state:     'WAIT'
    )
  end
end

class Enigma
  attr_reader :red
  attr_reader :blue
  attr_reader :yellow
  attr_reader :green
  attr_reader :target
  attr_reader :color

  def initialize
    @red    = OpenStruct.new(x: 0, y: 0)
    @blue   = OpenStruct.new(x: 0, y: 0)
    @yellow = OpenStruct.new(x: 0, y: 0)
    @green  = OpenStruct.new(x: 0, y: 0)
    @target = OpenStruct.new(x: 0, y: 0)
    @color  = OpenStruct.new
  end
end

$values = Shared.values
