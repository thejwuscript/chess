# frozen_string_literal: true

require_relative 'converter'

class Player
  
  attr_accessor :name, :color

  def initialize(name, color)
    @name = name
    @color = color
  end

end
