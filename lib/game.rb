# frozen_string_literal: true

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def place_on_board(piece)
    board.set_piece_at(piece.position, piece)
  end
end