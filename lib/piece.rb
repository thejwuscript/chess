#frozen_string_literal: true

class Piece
  attr_accessor :position, :color, :symbol, :type

  def initialize(color, position)
    @color = color || (self.class.initialize_count.even? ? 'W' : 'B')
    @position = position || assign_initial_position
    self.class.initialize_count += 1
    @symbol = assign_symbol
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end
end
