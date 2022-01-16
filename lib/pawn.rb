# frozen_string_literal: true

class Pawn
  attr_reader :position
  
  def initialize(color, position)
    @symbol = color == 'B' ? '♟︎' : '♙'
    @color = color
    @position = position
  end

  def update_position_to(position)
    @position = position
  end

end