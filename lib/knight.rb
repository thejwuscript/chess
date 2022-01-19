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
    self.position = ['B1', 'B8', 'G1', 'G8'][self.class.initialize_count]
    self.class.initialize_count += 1
  end
  
  def assign_symbol
    self.symbol = '♘' if @color == 'W'
    self.symbol = '♞' if @color == 'B'
  end
end