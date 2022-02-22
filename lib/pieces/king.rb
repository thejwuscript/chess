# frozen_string_literal: true

require_relative '../lib/piece'

class King < Piece
  attr_accessor :move_count
  @assignment_count = 0
  
  class << self
    attr_accessor :assignment_count
  end

  def initialize(color = nil, position = nil)
    super(color, position)
    @move_count = 0
    @type = 'king'
  end

  def assign_initial_position
    self.position = ['E1', 'E8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end

  def assign_symbol
    self.symbol = "♔" if @color == 'W'
    self.symbol = "♚" if @color == 'B'
  end

  def move_manner
    array = [1, 0, -1].repeated_permutation(2).to_a.reject { |ary| ary.all?(0) }
    castling_manner = [[0, 2], [0, -2]]
    move_count == 0 ? array + castling_manner : array
  end
end
