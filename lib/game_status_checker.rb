# frozen_string_literal: true

require_relative '../lib/move_examiner'

class GameStatusChecker
  attr_reader :color, :board, :game

  def initialize(color, board, game)
    @color = color
    @board = board
    @game = game
  end

  def no_legal_moves?
    board.all_allies(color).none? { |piece| piece.moves_available?(board, game) }
  end

  def king_in_check?
    array = board.find_checked_king
    king = array.find { |king| king.color == color } unless array.empty?

    target = king.position
    board.all_enemies(color).any? do |enemy|
      MoveExaminer.new(board, enemy, target, game).validate_move
    end
  end
end