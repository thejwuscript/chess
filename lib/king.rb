# frozen_string_literal: true

require_relative '../lib/piece'

class King < Piece
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'king'
  end

  def assign_initial_position
    self.position = ['E1', 'E8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end

  def assign_symbol
    self.symbol = '♔' if @color == 'W'
    self.symbol = '♚' if @color == 'B'
  end

end