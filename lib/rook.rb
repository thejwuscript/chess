# frozen_string_literal: true

require_relative '../lib/piece'

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
    self.symbol = '♖' if @color == 'W'
    self.symbol = '♜' if @color == 'B'
  end

  def move_manner
    [[1, 0],[-1, 0], [0, 1], [0,-1]]
  end

  def move_by(array) #necessary?
    position_to_array.zip(array).map { |a, b| a + b }
  end

  def within_limits?(array) #necessary?
    array.all? { |num| num.between?(0, 7) } ? true : false
  end

  def possible_moves #necessary?
    move_manner.map { |manner| move_by(manner) }
  end
  
  def filtered_possible_moves #necessary?
    possible_moves.keep_if { |ary| within_limits?(ary) }
  end

end