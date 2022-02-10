# frozen_string_literal: true

require_relative 'converter'

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
    row, column = array
    return false unless array.all? { |n| n.between?(0, 7) }
    return false if i < 3 && board.checked?(king, array_to_position(array))

    piece = board.grid[row][column + modifier]
    if piece.is_a?(Rook)
      piece.move_count == 0 ? true : false
    else
      return false unless piece.nil? 
      
      meet_castling_condition?([row, column + modifier], i += 1)
    end
  end

  private

  def modifier
    direction = (start_ary[1] - target_ary[1]).positive? ? 'Long' : 'Short'
    direction.eql?('Long') ? -1 : 1
  end
end