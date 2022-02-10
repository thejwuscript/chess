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

  def meet_castling_condition?(array = start_ary)
    row, column = array
    return false unless array.all? { |n| n.between?(0, 7) }
    return false if board.checked?(king, king.position)

    piece = board.grid[row][column + modifier]
    piece.nil? ? true : false
  end

  private

  def modifier
    direction = (start_ary[1] - target_ary[1]).positive? ? 'Long' : 'Short'
    direction.eql?('Long') ? -1 : 1
  end
end