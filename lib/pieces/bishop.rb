# frozen_string_literal: true

require_relative 'piece'

class Bishop < Piece
  @assignment_count = 0
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'bishop'
  end

  def assign_initial_position
    count = self.class.instance_variable_get(:@assignment_count)
    self.position = ['C1', 'C8', 'F1', 'F8'][count]
    self.class.instance_variable_set(:@assignment_count, count += 1)
  end
  
  def assign_symbol
    self.symbol = "♗" if @color == 'W'
    self.symbol = "#{black}♝" if @color == 'B'
  end

  def move_manner
    [[1, 1], [-1, -1], [-1, 1], [1, -1]]
  end
end