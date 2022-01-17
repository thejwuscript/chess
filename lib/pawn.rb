# frozen_string_literal: true

require_relative '../lib/piece'

class Pawn < Piece
  attr_reader :symbol
  
  def initialize(color, position)
    super # no need to take arguments for now
    @symbol = assign_symbol
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