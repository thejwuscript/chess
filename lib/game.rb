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
    player_turn
  end

  def setup
    assign_players
    show_player_assignment
    prep_board
  end

  def assign_players
    choose_game_message
    choice = choice_one_or_two
    p1 = HumanPlayer.new(get_name {'Player One'}, nil)
    p2 = choice == 1 ? ComputerPlayer.new('Computer', nil, board) :
                       HumanPlayer.new(get_name {'Player Two'}, nil)
    self.player_black, self.player_white = [p1, p2].shuffle
    player_black.color, player_white.color = 'B', 'W'
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
    board.show_board
    king_in_check_alert
    examiner = current_player.is_a?(HumanPlayer) ? player_move : computer_move
    finalize_move(examiner.piece, examiner)
    pawn_promotion
  end

  def computer_move
    examiner = current_player.choose_examiner(turn_count)
    board.show_color_guides_after_selection(examiner.piece, current_player, turn_count)
    examiner
  end

  def player_move
    piece = player_selection
    save_board_info
    board.show_color_guides_after_selection(piece, current_player, turn_count)
    player_target(piece)
  end

  def player_selection
    choose_piece_message(current_player)
    loop do
      input = current_player.input
      next save_game if input == 'S'
      next invalid_input_message if input == 'B'
      exit_game if input == 'Q'
      
      piece = board.piece_at(input)
      return piece if valid_selection?(piece)
      
      invalid_input_message
    end
  end

  def valid_selection?(piece)
    return false if piece.nil?

    piece.color == current_player.color && piece.moves_available?(board, turn_count)
  end

  def player_target(piece)
    choose_move_message(piece)
    loop do
      target = current_player.input
      return undo_selection(piece) if target == 'B'
      exit_game if target == 'Q'
      
      next invalid_input_message if target == 'S' || board.same_color_at?(target, piece)
      
      examiner = MoveExaminer.new(board, piece, target, turn_count)
      move_validated = examiner.validate_move
      return examiner if move_validated

      invalid_input_message
    end
  end

   def undo_selection(piece)
    hash = load_board_info
    piece.update_selected_value(false)
    board.grid = hash["grid"]
    board.origin_ary = hash["origin_ary"]
    board.attacking_arrays = hash['attacking_arrays']
    board.show_board
    player_move
  end

  def finalize_move(piece, examiner)
    target = examiner.target
    board.show_board_with_targeted_piece(position_to_array(target), current_player)
    board.move_piece_to_target(target, piece)
    piece.update_attributes_after_move(target)
    king_follow_through(piece, examiner) if piece.is_a?(King)
    pawn_follow_through(piece, examiner) if piece.is_a?(Pawn)
    
    board.show_board_with_delay(current_player)
  end

  def king_follow_through(king, examiner)
    target = examiner.target
    board.move_castle(target) if examiner.castling_verified
  end

  def pawn_follow_through(pawn, examiner)
    board.remove_pawn_captured_en_passant(pawn, examiner.target) if examiner.en_passant_verified
    pawn.store_turn_count(turn_count) if examiner.double_step_verified
  end

  def update_turn_count
    self.turn_count += 1
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def game_over?
    checker = GameStatusChecker.new(current_player.color, board, turn_count)
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
