# frozen_string_literal: true

require_relative '../lib/piece'

class Bishop < Piece
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'bishop'
  end

  def assign_initial_position
    self.position = ['C1', 'C8', 'F1', 'F8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end
  
  def assign_symbol
    self.symbol = '♝' if @color == 'W'
    self.symbol = "\e[30m♝" if @color == 'B'
  end

  def move_manner
    [[1, 1], [-1, -1], [-1, 1], [1, -1]]
  end

end