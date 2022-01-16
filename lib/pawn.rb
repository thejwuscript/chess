# frozen_string_literal: true

class Pawn
  attr_reader :position, :symbol
  
  def initialize(color, position)
    @color = color
    @symbol = assign_symbol
    @position = position
  end

  def update_position_to(position)
    @position = position
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end

  private

  def assign_symbol
    return '♙' if @color == 'W'
    return '♟︎' if @color == 'B'
  end

end