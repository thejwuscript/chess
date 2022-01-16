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

  private

  def assign_symbol
    return '♙' if @color == 'W'
    return '♟︎' if @color == 'B'
  end

end