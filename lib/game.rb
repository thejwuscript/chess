# frozen_string_literal: true

require_relative 'move_examiner'
require_relative '../lib/game_message'
require_relative 'save_and_load'
require 'yaml'
require_relative 'converter'
require 'pry-byebug'

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

  def new_game
    pregame
    round
    conclusion
  end

  def resume_game
    board.show_board
    king_in_check_alert
    current_player.player_move
    pawn_promotion
    round
    conclusion
  end
  
  def player_names
    get_name_message { 'Player One' }
    player_one_name = gets.chomp
    get_name_message { 'Player Two' }
    player_two_name = gets.chomp
    [player_one_name, player_two_name]
  end

  def assign_players
    names = player_names.shuffle
    self.player_white = HumanPlayer.new(names.first, 'W', board, self)
    self.player_black = HumanPlayer.new(names.last, 'B', board, self)
  end

  def prep_board
    all_pieces = create_all_pieces
    pieces_with_attributes = assign_attributes(all_pieces)
    set_pieces_on_board(pieces_with_attributes)
  end

  def create_all_pieces(array = [])
    16.times { array.push(Pawn.new) }
    [Rook, Bishop, Knight].each { |klass| 4.times { array << klass.new } }
    [Queen, King].each { |klass| 2.times { array << klass.new } }
    array
  end

  def assign_attributes(array)
    array.each_with_index do |piece, index|
      index.even? ? piece.color = 'W' : piece.color = 'B'
      piece.assign_symbol
      piece.assign_initial_position
    end
  end

  def set_pieces_on_board(array)
    array.each do |piece|
      board.set_piece_at(piece.position, piece)
    end
  end

  def pregame
    number = choose_game_format
    number == 1 ? assign_ai_player : assign_players
    show_player_assignment
    prep_board
  end

  def assign_ai_player
    get_name_message { 'Player One' }
    player_one_name = gets.chomp
    players = [HumanPlayer.new(player_one_name, nil, board, self), ComputerPlayer.new('Computer', nil, board, self)].shuffle
    self.player_black, self.player_white = players
    player_black.color = 'B'
    player_white.color = 'W'
  end

  def choose_game_format
    choose_game_message
    loop do
      input = gets.chomp.to_i
      return input if input.between?(1, 2)

      invalid_input_message
    end
  end

  def round
    loop do
      board.show_board
      update_turn_count
      change_player
      return if game_over?

      king_in_check_alert
      current_player.player_move
      pawn_promotion
    end
  end

  def update_turn_count
    self.turn_count += 1
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def king_in_check_alert
    king_in_check = board.find_own_king_in_check(current_player.color)
    king_checked_message(king_in_check) if king_in_check
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
    piece.assign_symbol
    board.set_piece_at(piece.position, piece)
    board.show_board
    ai_promote_message(piece) if current_player.is_a?(ComputerPlayer)
  end

  def conclusion
    winner ? declare_winner : declare_draw
  end
end
