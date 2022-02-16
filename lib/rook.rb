# frozen_string_literal: true

require_relative 'piece'

class Rook < Piece
  
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'rook'
  end

  def assign_initial_position
    self.position = ['A1', 'A8', 'H1', 'H8'][self.class.assignment_count]
    self.class.assignment_count += 1
  end
  
  def assign_symbol
    self.symbol = "♖" if @color == 'W'
    self.symbol = "♜" if @color == 'B'
  end

  def move_manner
    [[1, 0],[-1, 0], [0, 1], [0,-1]]
  end

end