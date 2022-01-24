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

  def move_manner
    [1, 0, -1].repeated_permutation(2).to_a.reject { |ary| ary.all?(0) }
  end

  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

  def possible_arrays
    unfiltered = move_manner.map do |manner| 
      position_to_array.zip(manner).map { |a, b| a + b }
    end
    unfiltered.keep_if { |item| within_limits?(item) }
  end

  def possible_positions
    possible_arrays.map { |array| array_to_position(array) }
  end

end