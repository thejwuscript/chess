# frozen_string_literal: true

require_relative 'converter'
require_relative 'game_status_checker'
require_relative 'move_examiner'

class CastlingChecker
  include Converter
  attr_reader :board, :king, :target_ary, :start_ary

  def initialize(board, king, target_ary)
    @board = board
    @king = king
    @target_ary = target_ary
    @start_ary = position_to_array(king.position)
  end

  def meet_castling_condition?(array = start_ary, i = 0)
    return false unless meet_prerequisites?(array, i)

    row, column = array
    piece = next_piece(row, column)
    if piece.is_a?(Rook)
      piece.move_count == 0 ? true : false
    else
      next_ary = [row, column + modifier]
      piece.nil? ? meet_castling_condition?(next_ary, i += 1) : false
    end
  end

  private

  def modifier
    direction = (start_ary[1] - target_ary[1]).positive? ? 'Long' : 'Short'
    direction.eql?('Long') ? -1 : 1
  end

  def meet_prerequisites?(array, count)
    return false unless board.within_limits?(array)
    return true if count > 2
    
    position = array_to_position(array)
    original_piece = board.piece_at(position)
    board.move_piece_to_target(position, king) unless count == 0
    
    game_status_checker = GameStatusChecker.new(king.color, board)
    result = game_status_checker.own_king_in_check?(position) ? false : true
    board.set_piece_at(position, original_piece) unless count == 0
    
    board.set_piece_at(king.position, king)
    result
  end

  def next_piece(row, column)
    board.grid[row][column + modifier]
  end
end
