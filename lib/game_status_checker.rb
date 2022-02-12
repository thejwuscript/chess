# frozen_string_literal: true

require_relative '../lib/move_examiner'

class GameStatusChecker
  attr_reader :color, :board, :game

  def initialize(color, board, game = nil) #game object is optional.
    @color = color
    @board = board
    @game = game
  end

  def no_legal_moves?
    board.all_allies(color).none? { |piece| piece.moves_available?(board, game) }
  end

  def own_king_in_check? # no need for game instant variable here. The 'target' is the king.
    king = board.find_own_king(color)
    target = king.position
    board.all_enemies(color).any? do |enemy|
      MoveExaminer.new(board, enemy, target).validate_move
    end
  end
end