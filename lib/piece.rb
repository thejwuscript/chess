#frozen_string_literal: true

require_relative 'move_examiner'
require_relative 'converter'
require_relative 'limiter'

class Piece
  include Converter
  include Limiter
  
  attr_accessor :position, :color, :symbol, :type, :move_count, :selected

  def initialize(color, position)
    @color = color
    @position = position
    @symbol = assign_symbol
    @move_count = 0
    @selected = false
  end

  def initial_positions_and_symbol
    assign_initial_position
    assign_symbol
  end

  def update_selected_value(value)
    self.selected = value
  end

  def all_squares(array = [])
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    array
  end

  def available_moves(board, game, array = [])
    all_squares.each do |square|
      examiner = MoveExaminer.new(board, self, square, game)
      array << square if examiner.validate_move 
    
    end
    array
  end

  def moves_available?(board, game)
    all_squares.any? do |square|
      examiner = MoveExaminer.new(board, self, square, game)
      examiner.validate_move
    end
  end

  def depth_search_coords(start_ary, manner, result = [])
    next_ary = start_ary.zip(manner).map { |a, b| a + b }
    return result unless within_limits?(next_ary)
    
    result << next_ary
    depth_search_coords(next_ary, manner, result)
  end

  def generate_coordinates
    start_ary = position_to_array
    case self
    when Rook, Bishop, Queen
      move_manner.flat_map { |manner|  depth_search_coords(start_ary, manner) }
    when Knight, King, Pawn
      move_manner.filter_map do |manner| 
        combined = start_ary.zip(manner).map { |a, b| a + b }
        combined if within_limits?(combined)
      end
    end
  end

  def possible_targets
    generate_coordinates.map { |coord| array_to_position(coord) }
  end

  def verified_target_arrays(board, game)
    possible_targets.filter_map do |target| 
      examiner = MoveExaminer.new(board, self, target, game)
      position_to_array(target) if examiner.validate_move
    end
  end
end
