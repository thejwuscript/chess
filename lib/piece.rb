#frozen_string_literal: true

class Piece
  attr_accessor :position, :color, :symbol, :type

  def initialize(color, position)
    @color = color
    @position = position
    @symbol = assign_symbol
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end

  def array_to_position(array)
    letter = ('A'..'Z').to_a[array.last]
    number = (1..8).to_a.reverse[array.first]
    "#{letter}#{number}"
  end
end
