# frozen_string_literal: true

require_relative '../lib/piece'

class Pawn < Piece
  attr_reader :type
  
  def initialize
    super
    @type = 'pawn'
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
