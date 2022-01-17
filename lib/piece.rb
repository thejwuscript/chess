#frozen_string_literal: true

class Piece
  attr_reader :position
  
  def initialize(color, position)
    @color = color
    @position = position
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end
end