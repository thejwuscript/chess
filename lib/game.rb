# frozen_string_literal: true

class Game
  attr_reader :board, :all_pieces

  def initialize
    @board = Board.new
    @all_pieces = []
  end

  def create_all_pieces
    16.times { all_pieces.push(Pawn.new) }
    [Rook, Bishop, Knight].each { |klass| 4.times { all_pieces << klass.new }}
    [Queen, King].each { |klass| 2.times { all_pieces << klass.new }}
  end
    
  def assign_all_colors
    all_pieces.each_with_index do |piece, index|
      index.even? ? piece.color = 'W' : piece.color = 'B'
    end
  end

  def assign_all_symbols
    all_pieces.each { |piece| piece.assign_symbol }
  end

  def assign_all_positions
    all_pieces.each { |piece| piece.assign_initial_position }
  end

  def set_initial_positions
    all_pieces.each do |piece|
      board.set_piece_at(piece.position, piece)
    end
  end

end

=begin
def arrange_all_pieces
    create_all_pieces.reduce(Hash.new) do |result, piece|
      result.key?(piece.type) ? 
        result[piece.type].push(piece) : result[piece.type] = [piece]
      result
    end
  end
=end
