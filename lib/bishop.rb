# frozen_string_literal: true

require_relative '../lib/piece'

class Bishop < Piece
  @initialize_count = 0

  class << self
    attr_accessor :initialize_count
  end
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'bishop'
  end

  def assign_initial_position
    ['C1', 'C8', 'F1', 'F8'][self.class.initialize_count]
  end
  
  
  private
  
  def assign_symbol
    return '♗' if @color == 'W'
    return '♝' if @color == 'B'
  end

end