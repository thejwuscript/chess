# frozen_string_literal: true

class Game
  attr_reader :board, :all_pieces

  def initialize
    @board = Board.new
    @all_pieces = arrange_all_pieces
    set_initial_positions
  end

  def set_initial_positions
    all_pieces.each do |key, value|
      value.each { |piece| board.set_piece_at(piece.position, piece) }
    end
  end

  def create_all_pieces(array = [])
    16.times { array.push(Pawn.new) }
    4.times { array.push(Rook.new, Bishop.new, Knight.new) }
    2.times { array.push(Queen.new, King.new) }
    array
  end

  def arrange_all_pieces
    create_all_pieces.reduce(Hash.new) do |result, piece|
      result.key?(piece.type) ? 
        result[piece.type].push(piece) : result[piece.type] = [piece]
      result
    end
  end

end
