# frozen_string_literal: true

require_relative 'piece'

class Pawn < Piece
  attr_accessor :move_count, :start_position, :double_step_turn
  @assignment_count = 0
  
  def initialize(color = nil, position = nil)
    super(color, position)
    @type = 'pawn'
    @start_position = position || nil
    @move_count = 0
    @double_step_turn = 0
  end

  def assign_initial_position
    ary = ('A'..'H').flat_map { |letter| ["#{letter}2", "#{letter}7"] }
    count = self.class.instance_variable_get(:@assignment_count)
    self.position = ary[count]
    self.start_position = ary[count]
    self.class.instance_variable_set(:@assignment_count, count += 1)
  end

  def assign_symbol
    self.symbol = "♙" if @color == 'W'
    self.symbol = "♟" if @color == 'B'
  end

  def en_passantable?(color, turn)
    true if en_passant_position? && en_passantable_turn?(turn)
  end

  def en_passant_position?
    true if color == 'B' && position[1].to_i == 5 || 
            color == 'W' && position[1].to_i == 4
  end

  def en_passantable_turn?(current_turn)
    current_turn - double_step_turn == 1 ? true : false
  end

  def store_turn_count(count)
    self.double_step_turn = count
  end

  def move_manner
    if color == 'W'
      [[-1, 0], [-2, 0], [-1, 1], [-1, -1]]
    elsif color == 'B'
      [[1, 0], [2, 0], [1, 1], [1, -1]]
    end
  end
end
