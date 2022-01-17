#frozen_string_literal: true

class Piece
  attr_accessor :position, :color, :symbol
  
  def initialize
    @color = nil
    @position = nil
    @symbol = assign_symbol
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end
end
