# frozen_string_literal: true

require_relative '../lib/game_message'

class Game
  include GameMessage
  
  attr_reader :board, :all_pieces
  attr_accessor :turn_count, :current_player, :player_white, :player_black
  
  def initialize
    @board = Board.new
    @all_pieces = []
    @turn_count = 0
    @player_white = nil
    @player_black = nil
    @current_player = nil
  end

  def player_names
    get_name_message { 'one' }
    player_one_name = gets.chomp
    get_name_message { 'two' }
    player_two_name = gets.chomp
    [player_one_name, player_two_name]
  end

  def assign_players
    names = player_names.shuffle
    self.player_white = Player.new(names.first, 'W')
    self.player_black = Player.new(names.last, 'B')
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def prep_board
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

  def player_input
    enter_input_message
    input = gets.chomp.upcase
    return input if input.match?(/^[A-H][1-8]$/)

    invalid_input_message
    player_input
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

  
  def select_piece
    puts 'Enter a coordinate to select a piece.'
    input = gets.chomp.upcase
    board.piece_at(input)
  end
=end
