# frozen_string_literal: true

require_relative 'converter'
require_relative 'board_display'
require_relative 'game_status_checker'

class Board
  include Converter
  include BoardDisplay

  attr_reader :grid, :origin_ary, :attacking_arrays
  
  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @origin_ary = nil
    @attacking_arrays = []
  end

  def piece_at(position)
    row, column = position_to_array(position)
    grid[row][column]
  end

  def set_piece_at(position, piece)
    row, column = position_to_array(position)
    grid[row][column] = piece
  end

  def delete_piece_at(position)
    row, column = position_to_array(position)
    grid[row][column] = nil
  end

  def find_own_king(color)
    grid.flatten.find { |piece| piece.is_a?(King) && piece.color == color }
  end

  def find_own_king_in_check(color)
    king = find_own_king(color)
    GameStatusChecker.new(color, self).own_king_in_check? ? king : nil
  end

  def promotion_candidate
    array = grid[0] + grid[7]
    array.detect { |piece| piece.is_a? Pawn }
  end

  def occupied?(array)
    row, column = array
    grid[row][column] ? true : false
  end

  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

  def same_color_at?(position, piece)
    if other_piece = piece_at(position)
      piece.color == other_piece.color ? true : false
    end
  end

  def enemies_giving_check(own_color, target = nil)
    target ||= find_own_king(own_color).position
    all_enemies(own_color).keep_if do |enemy|
      MoveExaminer.new(self, enemy, target).search_target
    end
  end

  def remove_pawn_captured_en_passant(piece, target)
    row, column = position_to_array(target)
    modifier = piece.color == 'W' ? 1 : -1
    grid[row + modifier].insert(column + 1, nil)
    grid[row + modifier].delete_at(column)
  end

  def move_piece_to_target(target, piece)
    set_piece_at(target, piece)
    delete_piece_at(piece.position)
  end

  def move_castle(target)
    where_rook_is, destination = case target
                                 when 'C8' then ['A8', 'D8']
                                 when 'G8' then ['H8', 'F8']
                                 when 'C1' then ['A1', 'D1']
                                 when 'G1' then ['H1', 'F1']
                                 end
    rook = piece_at(where_rook_is)
    move_piece_to_target(destination, rook)
  end

  def all_enemies(own_color)
    grid.flatten.reject { |piece| piece.nil? || piece.color == own_color }
  end

  def all_allies(color)
    grid.flatten.compact.keep_if { |piece| piece.color == color }
  end

  def return_state(hash)
    @grid = hash["grid"]
    @origin_ary = hash["origin_ary"]
    @attacking_arrays = hash['attacking_arrays']
  end
end
