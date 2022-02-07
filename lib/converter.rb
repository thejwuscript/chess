# frozen_string_literal: true

module Converter
  def array_to_position(array)
    letter = ('A'..'Z').to_a[array.last]
    number = (1..8).to_a.reverse[array.first]
    letter + number.to_s
  end
  
  def position_to_array(position)
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end
end