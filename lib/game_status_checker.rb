# frozen_string_literal: true

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

end