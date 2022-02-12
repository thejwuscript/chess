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

  def own_king_in_check?
    board.enemies_giving_check(color).any?
  end
end