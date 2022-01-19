# frozen_string_literal: true

require_relative '../lib/piece'

class Bishop < Piece
  @initialize_count = 0

  class << self
    attr_accessor :initialize_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'bishop'
  end

  def assign_initial_position
    self.position = ['C1', 'C8', 'F1', 'F8'][self.class.initialize_count]
    self.class.initialize_count += 1
  end
  
  def assign_symbol
    self.symbol = '♗' if @color == 'W'
    self.symbol = '♝' if @color == 'B'
  end

end