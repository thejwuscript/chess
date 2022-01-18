# frozen_string_literal: true

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def place_on_board(piece)
    board.set_piece_at(piece.position, piece)
  end

  def create_all_pieces(array = [])
    16.times { array.push(Pawn.new) }
    4.times { array.push(Rook.new, Bishop.new, Knight.new) }
    2.times { array.push(Queen.new, King.new) }
    array
  end

end
