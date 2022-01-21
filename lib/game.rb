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

  def assign_all_attributes
    all_pieces.each_with_index do |piece, index|
      index.even? ? piece.color = 'W' : piece.color = 'B'
      piece.assign_symbol
      piece.assign_initial_position
    end
  end

  def set_initial_positions
    all_pieces.each do |piece|
      board.set_piece_at(piece.position, piece)
    end
  end

  def move_piece
    selected_piece = select_piece
    puts 'Enter a coordinate to move the piece to.'
    input = gets.chomp.upcase
    if selected_piece.is_a? Rook
      return unless board.validate_rook_move(selected_piece, input)
    end
    board.set_piece_at(input, selected_piece)
    board.delete_piece_at(selected_piece.position)
    selected_piece.position = input
  end

  private

  def select_piece
    puts 'Enter a coordinate to select a piece.'
    input = gets.chomp.upcase
    board.piece_at(input)
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
