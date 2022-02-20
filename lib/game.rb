# frozen_string_literal: true

require_relative 'move_examiner'
require_relative '../lib/game_message'
require_relative 'save_and_load'
require 'yaml'
require_relative 'converter'

class Game
  include GameMessage
  include Converter
  include SaveAndLoad

  attr_accessor :board, :turn_count, :current_player, :player_white, :player_black, :winner
  
  def initialize
    @board = Board.new
    @turn_count = 0
    @player_white = nil
    @player_black = nil
    @current_player = nil
    @winner = nil
  end

  def play(num)
    num == 1 ? setup : resume_game
    round
    conclusion
  end

  def resume_game
    game_loaded_message
    board.show_board
    player_turn
  end

  def setup
    assign_players
    show_player_assignment
    prep_board
    board.show_board
  end

  def assign_players
    choose_game_message
    choice = choice_one_or_two
    p1 = HumanPlayer.new(get_name {'Player One'}, nil, board, self)
    p2 = choice == 1 ? ComputerPlayer.new('Computer', nil, board, self) :
                       HumanPlayer.new(get_name {'Player Two'}, nil, board, self)
    self.player_black, self.player_white = [p1, p2].shuffle
    player_black.color, player_white.color = 'B', 'W'
  end

  def get_name
    print "\n#{yield}, please enter your name: "
    gets.chomp
  end

  def choice_one_or_two
    loop do
      input = gets.chomp
      return input.to_i if input == '1' || input == '2'

      invalid_input_message
    end
  end

  def prep_board
    pieces_with_attributes = assign_attributes(all_pieces)
    set_pieces_on_board(pieces_with_attributes)
  end

  def all_pieces(array = [])
    16.times { array.push(Pawn.new) }
    [Rook, Bishop, Knight].each { |klass| 4.times { array << klass.new } }
    [Queen, King].each { |klass| 2.times { array << klass.new } }
    array
  end

  def assign_attributes(chess_pieces)
    chess_pieces.each_with_index do |piece, index|
      index.even? ? piece.color = 'W' : piece.color = 'B'
      piece.initial_positions_and_symbol
    end
  end

  def set_pieces_on_board(chess_pieces)
    chess_pieces.each { |piece| board.set_piece_at(piece.position, piece) }
  end

  def round
    loop do
      update_turn_count
      change_player
      return if game_over?

      player_turn
    end
  end

  def player_turn
    king_in_check_alert
    current_player.player_move
    pawn_promotion
  end

  def update_turn_count
    self.turn_count += 1
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def game_over?
    checker = GameStatusChecker.new(current_player.color, board, self)
    if checker.stalemate?
      true
    elsif checker.checkmate?
      self.winner = current_player.color == 'W' ? player_black : player_white
      true
    else 
      false
    end
  end

  def pawn_promotion
    pawn = board.promotion_candidate
    return if pawn.nil?

    number = current_player.promotion_choice
    piece = [Queen, Rook, Bishop, Knight][number - 1].new(pawn.color, pawn.position)
    set_new_promoted_piece(piece)
    board.show_board
    ai_promote_message(piece) if current_player.is_a?(ComputerPlayer)
  end

  def set_new_promoted_piece(new_piece)
    new_piece.assign_symbol
    new_piece.update_selected_value(true)
    board.set_piece_at(new_piece.position, new_piece)
  end

  def conclusion
    winner ? declare_winner : declare_draw
  end

  def exit_game
    board.show_board_on_quit
    puts "\nThanks for playing."
    exit
  end
end
