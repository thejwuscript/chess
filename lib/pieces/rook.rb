# frozen_string_literal: true

require_relative 'piece'

class Rook < Piece
  attr_accessor :move_count
  @assignment_count = 0
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @move_count = 0
    @type = 'rook'
  end

  def assign_initial_position
    count = self.class.instance_variable_get(:@assignment_count)
    self.position = ['A1', 'A8', 'H1', 'H8'][count]
    self.class.instance_variable_set(:@assignment_count, count += 1)
  end
  
  def assign_symbol
    self.symbol = "♖" if @color == 'W'
    self.symbol = "#{black}♜" if @color == 'B'
  end

  def move_manner
    [[1, 0],[-1, 0], [0, 1], [0,-1]]
  end
end
