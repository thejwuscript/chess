# frozen_string_literal: true

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def pregame
    create_white_pieces
    create_black_pieces
    place_on_board(@pawn1)
    place_on_board(@pawn2)
    place_on_board(@pawn3)
    place_on_board(@pawn4)
    board.show_board
  end

  def place_on_board(piece)
    board.set_piece_at(piece.position, piece)
  end

  def create_white_pieces(color = 'W')
    @pawn1 = Pawn.new(color, 'D2')
    @pawn2 = Pawn.new(color, 'E2')
  end

  def create_black_pieces(color = 'B')
    @pawn3 = Pawn.new(color, 'D7')
    @pawn4 = Pawn.new(color, 'E7')
  end
end