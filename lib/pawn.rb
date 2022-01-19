# frozen_string_literal: true

require_relative '../lib/piece'

class Pawn < Piece
  @initialize_count = 0

  class << self
    attr_accessor :initialize_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'pawn'
  end

  def assign_initial_position
    ary = ('A'..'H').flat_map { |letter| ["#{letter}2", "#{letter}7"] }
    self.position = ary[self.class.initialize_count]
    self.class.initialize_count += 1
  end

  def assign_symbol
    self.symbol = '♙' if @color == 'W'
    self.symbol = '♟︎' if @color == 'B'
  end
end
