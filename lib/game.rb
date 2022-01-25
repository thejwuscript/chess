# frozen_string_literal: true

require_relative '../lib/game_message'

class Game
  include GameMessage
  
  attr_reader :board, :all_pieces
  attr_accessor :turn_count, :current_player, :player_white, :player_black, :winner
  
  def initialize
    @board = Board.new
    @all_pieces = []
    @turn_count = 0
    @player_white = nil
    @player_black = nil
    @current_player = nil
    @winner = nil
  end

  def play
    puts "Welcome to CHESS."
    the_game
  end

  def the_game
    pregame
    round
    game_end
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

  def prep_board
    create_all_pieces
    assign_all_attributes
    set_initial_positions
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

  def pregame
    assign_players
    prep_board
  end

  def round
    board.show_board
    update_turn_counts
    change_player
    return if game_over?

    move_piece
    round
  end

  def update_turn_counts
    self.turn_count += 1
    board.grid.flatten.compact.each { |piece| piece.turn_count += 1 }
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def move_piece
    move_king if board.find_checked_king

    chosen_piece = board.piece_at(verify_input_one)
    target = verify_input_two(chosen)
    verified_move = board.validate_move(chosen_piece, target)
    finalize_move(chosen_piece, verified_move)
  end

  def move_king
    # code here...
  end

  def finalize_move(piece, target)
    board.set_piece_at(target, piece)
    board.delete_piece_at(piece.position)
    piece.position = target
  end

  def player_input
    enter_input_message
    input = gets.chomp.upcase
    return input if input.match?(/^[A-H][1-8]$/)

    invalid_input_message
    player_input
  end

  def verify_input_one
    loop do
      input = player_input
      return input if board.piece_at(input).color == current_player.color

      invalid_input_message
    end
  end

  def verify_input_two(piece)
    loop do
      input = player_input
      return input unless board.same_color_at?(input, piece)

      invalid_input_message
    end
  end

  def game_over?
    return false if king = board.find_checked_king.nil?
    return true if stalemate?(king)
    
    if checkmate?(king)
      self.winner = king.color == 'W' ? player_black : player_white
      true
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
