#frozen_string_literal: true

require_relative '../move_examiners/move_examiner'
require_relative '../converter'

class Piece
  include Converter
  
  attr_accessor :position, :color, :symbol, :selected
  attr_reader :type

  def initialize(color, position)
    @color = color
    @position = position
    @symbol = assign_symbol
    @selected = false
  end

  def initial_positions_and_symbol
    assign_initial_position
    assign_symbol
  end

  def update_selected_value(value)
    self.selected = value
  end

  def update_position(value)
    self.position = value
  end

  def all_squares(array = [])
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    array
  end

  def moves_available?(board, turn)
    all_squares.any? do |square|
      examiner = MoveExaminer.new(board, self, square, turn)
      examiner.validate_move
    end
  end

  def depth_search_coords(start_ary, manner, board, result = [])
    next_ary = start_ary.zip(manner).map { |a, b| a + b }
    return result unless board.within_limits?(next_ary)
    
    result << next_ary
    depth_search_coords(next_ary, manner, board, result)
  end

  def generate_coordinates(board)
    start_ary = position_to_array
    case self
    when Rook, Bishop, Queen
      move_manner.flat_map { |manner|  depth_search_coords(start_ary, manner, board) }
    when Knight, King, Pawn
      move_manner.filter_map do |manner| 
        combined = start_ary.zip(manner).map { |a, b| a + b }
        combined if board.within_limits?(combined)
      end
    end
  end

  def possible_targets(board)
    generate_coordinates(board).map { |coord| array_to_position(coord) }
  end

  def approved_examiners(board, turn)
    possible_targets(board).filter_map do |target|
      examiner = MoveExaminer.new(board, self, target, turn)
      examiner if examiner.validate_move
    end
  end

  def verified_targets(board, turn)
    approved_examiners(board, turn).map { |examiner| examiner.target }
  end

  def verified_target_arrays(board, turn)
    verified_targets(board, turn).map { |target| position_to_array(target) }
  end
  
  def update_attributes_after_move(target)
    self.position = target
    self.move_count += 1 if [King, Rook, Pawn].include?(self.class)
  end
end
