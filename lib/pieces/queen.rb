# frozen_string_literal: true

require_relative 'piece'

class Queen < Piece
  @assignment_count = 0

  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'queen'
  end

  def assign_initial_position
    count = self.class.instance_variable_get(:@assignment_count)
    self.position = ['D1', 'D8'][count]
    self.class.instance_variable_set(:@assignment_count, count += 1)
  end
  
  def assign_symbol
    self.symbol = "♕" if @color == 'W'
    self.symbol = "♛" if @color == 'B'
  end

  def move_manner
    [1, 0, -1].repeated_permutation(2).to_a.reject { |ary| ary.all?(0) }
  end
end
