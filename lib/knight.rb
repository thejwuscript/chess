# frozen_string_literal: true

require_relative '../lib/piece'

class Knight < Piece
  @initialize_count = 0

  class << self
    attr_accessor :initialize_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'knight'
  end

  def assign_initial_position
    ['B1', 'B8', 'G1', 'G8'][self.class.initialize_count]
  end
  
  
  private
  
  def assign_symbol
    return '♘' if @color == 'W'
    return '♞' if @color == 'B'
  end
end