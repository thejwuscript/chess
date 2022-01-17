# frozen_string_literal: true

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def place_on_board(piece)
    board.set_piece_at(piece.position, piece)
  end

  def create_promoted_pieces(array = [])
    [Rook, Knight, Bishop].each do |klass|
      2.times { array.push(klass.new) }
    end
    [Queen, King].each { |klass| array.push(klass.new) }
    array
  end
      

end

=begin
def pregame
  create_white_pieces
  create_black_pieces
  place_on_board(@pawn_D2)
  place_on_board(@pawn_E2)
  place_on_board(@pawn_D7)
  place_on_board(@pawn_E7)
  board.show_board
end

def create_white_pieces(color = 'W')
  @pawn_D2 = Pawn.new(color, 'D2')
  @pawn_E2 = Pawn.new(color, 'E2')
end

def create_black_pieces(color = 'B')
  @pawn_D7 = Pawn.new(color, 'D7')
  @pawn_E7 = Pawn.new(color, 'E7')
end
=end
