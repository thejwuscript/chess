# frozen_string_literal: true

require_relative '../lib/piece'

class Pawn < Piece
  attr_accessor :move_count
  attr_reader :start_position
  
  @assignment_count = 0

  class << self
    attr_accessor :assignment_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'pawn'
    @start_position = nil
    @move_count = 0
  end

  def assign_initial_position
    ary = ('A'..'H').flat_map { |letter| ["#{letter}2", "#{letter}7"] }
    self.position = ary[self.class.assignment_count]
    self.start_position = ary[self.class.assignment_count]
    self.class.assignment_count += 1
  end

  def assign_symbol
    self.symbol = '♙' if @color == 'W'
    self.symbol = '♟︎' if @color == 'B'
  end
end
