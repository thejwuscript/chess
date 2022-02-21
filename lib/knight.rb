# frozen_string_literal: true

require_relative '../lib/piece'

class Knight < Piece
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'knight'
  end

  def assign_initial_position
    self.position = ['B1', 'B8', 'G1', 'G8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end
  
  def assign_symbol
    self.symbol = "♘" if @color == 'W'
    self.symbol = "♞" if @color == 'B'
  end

  def move_manner
  [2, 1, -1, -2].permutation(2).to_a.reject { |ary| (ary[0]).abs == (ary[1]).abs }
  end
end