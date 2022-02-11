# frozen_string_literal: true

require_relative '../lib/movement'
require_relative '../lib/converter'
require_relative 'move_examiner'
require_relative 'board_display'

class Board
  include Converter
  include BoardDisplay
  
  attr_reader :grid
  
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def piece_at(position) # UPPERCASE
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

  def find_checked_king(array = [])
    kings = grid.flatten.keep_if { |piece| piece.is_a? King }
    kings.each { |king| array << king if checked?(king, king.position) }
    array
  end

  def promote_candidate
    array = grid[0] + grid[7]
    array.detect { |piece| piece.is_a? Pawn }
  end

  def occupied?(array)
    row, column = array
    grid[row][column] ? true : false
  end

  def same_color_at?(position, piece)
    if other_piece = piece_at(position)
      piece.color == other_piece.color ? true : false
    end
  end

  def checked?(king, target)
    color = king.color
    all_enemies(color).any? { |enemy| validate_move(enemy, target) == target }
  end

  def remove_pawn_captured_en_passant(piece, target, game)
    return unless piece.is_a?(Pawn) && target.match?(/3|6/)
    
    a, b = position_to_array(target)
    w_en_passant(a, b, game) ? grid[a+1][b] = nil : nil
    b_en_passant(a, b, game) ? grid[a-1][b] = nil : nil
  end

  def move_piece_to_target(target, piece)
    set_piece_at(target, piece)
    delete_piece_at(piece.position)
    piece.position = target
  end

  def move_castle(target)
    row = target[1]
    if target[0] == 'C'
      rook = piece_at("A#{row}")
      set_piece_at("D#{row}", rook)
      delete_piece_at(rook.position)
      rook.position = "D#{row}"
    elsif target[0] == 'G'
      rook = piece_at("H#{row}")
      set_piece_at("F#{row}", rook)
      delete_piece_at(rook.position)
      rook.position = "F#{row}"
    end
  end

  def all_enemies(color)
    grid.flatten.reject { |piece| piece.nil? || piece.color == color }
  end

  def checkmate?(king, game)
    no_legal_moves?(king.color, game) && checked?(king, king.position) && no_counterattack?(king, king.color)
  end

  def stalemate?(king, game)
    no_legal_moves?(king.color, game) && !(checked?(king, king.position)) && no_counterattack?(king, king.color)
  end

  def no_legal_moves?(color, game)
    all_allies(color).none? { |piece| moves_available?(piece, game) }
  end

  def enemies_checking(king, target)
    color = king.color
    all_enemies(color).each { |enemy| return enemy if validate_move(enemy, target) == target }[0]
  end

  def all_allies(color)
    grid.flatten.compact.keep_if { |piece| piece.color == color }
  end

  def no_counterattack?(king, color)
    target = enemies_checking(king, king.position).position
    all_allies(color).none? { |ally| validate_move(ally, target) }
  end

  private
  
end
