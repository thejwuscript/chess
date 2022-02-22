# frozen_string_literal: true

require_relative '../lib/piece'

class Queen < Piece
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'queen'
  end

  def assign_initial_position
    self.position = ['D1', 'D8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end
  
  def assign_symbol
    self.symbol = "♕" if @color == 'W'
    self.symbol = "♛" if @color == 'B'
  end

  def move_manner
    [1, 0, -1].repeated_permutation(2).to_a.reject { |ary| ary.all?(0) }
  end
end
