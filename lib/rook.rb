# frozen_string_literal: true

require_relative '../lib/piece'

class Rook < Piece
  @initialize_count = 0

  class << self
    attr_accessor :initialize_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'rook'
  end

  def assign_initial_position
    ['A1', 'A8', 'H1', 'H8'][self.class.initialize_count]
  end
  
  private
  
  def assign_symbol
    return '♖' if @color == 'W'
    return '♜' if @color == 'B'
  end
end