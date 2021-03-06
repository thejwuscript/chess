# frozen_string_literal: true

require_relative 'move_examiners/move_examiner'
require_relative 'game_message'
require_relative 'save_and_load'
require_relative 'converter'
require 'yaml'

class Game
  include GameMessage
  include Converter
  include SaveAndLoad

  attr_accessor :turn_count, :draw_count, :current_player, :player_white, :player_black, :winner
  attr_reader :board, :pawn_positions, :active_pieces
  
  def initialize
    @board = Board.new
    @turn_count = 0
    @draw_count = 0
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
    p1 = HumanPlayer.new(get_name {'Player One'})
    p2 = choice == 1 ? ComputerPlayer.new('Computer', board) :
                       HumanPlayer.new(get_name {'Player Two'})
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

      store_pawn_positions_and_piece_count
      player_turn
    end
  end

  def store_pawn_positions_and_piece_count
    @pawn_positions = board.pawn_positions
    @active_pieces = board.number_of_pieces
  end

  def player_turn
    board.show_board
    king_in_check_alert
    save_board_info
    examiner = current_player.is_a?(HumanPlayer) ? player_move : computer_move
    finalize_move(examiner.piece, examiner)
    pawn_promotion
  end

  def computer_move
    examiner = current_player.choose_examiner(turn_count)
    board.show_color_guides(current_player, examiner.piece)
    examiner
  end

  def player_move
    piece = select_piece
    examiners = piece.approved_examiners(board, turn_count)
    board.show_color_guides(current_player, piece, examiners)
    player_target(examiners)
  end

  def select_piece
    choose_piece_message(current_player)
    loop do
      case input = current_player.input
      when 'S' then next save_game
      when 'Q' then exit_game
      when 'B' then next invalid_input_message
      else
        return board.piece_at(input) if valid_selection?(input)

        invalid_input_message
      end
    end
  end

  def valid_selection?(input)
    piece = board.piece_at(input)
    return false if piece.nil?

    piece.color == current_player.color && piece.moves_available?(board, turn_count)
  end

  def player_target(examiners)
    choose_move_message(examiners[0].piece)
    loop do
      case input = current_player.input
      when 'B' then return undo(examiners[0].piece)
      when 'Q' then exit_game
      when 'S' then next invalid_input_message
      else 
        examiners.each { |examiner| return examiner if examiner.target == input }

        invalid_input_message
      end 
    end
  end

  def undo(piece)
    hash = load_board_info
    piece.update_selected_value(false)
    board.return_state(hash)
    board.show_board
    player_move
  end

  def finalize_move(piece, examiner)
    target = examiner.target
    board.show_board_with_targeted_piece(position_to_array(target), current_player)
    board.move_piece_to_target(target, piece)
    piece.update_attributes_after_move(target)
    board.move_castle(target) if examiner.castling_verified
    board.remove_pawn_captured_en_passant(piece, target) if examiner.en_passant_verified
    piece.store_turn_count(turn_count) if examiner.double_step_verified
    
    board.show_board_with_delay(current_player)
  end

  def update_turn_count
    self.turn_count += 1
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def update_draw_count
    no_game_progress? ? self.draw_count += 1 : self.draw_count = 0
  end

  def no_game_progress?
    board.pawn_positions == @pawn_positions && board.number_of_pieces == @active_pieces
  end

  def game_over?
    update_draw_count
    checker = GameStatusChecker.new(current_player.color, board, turn_count)
    if draw_count == 50
      fifty_move_rule_message
      true
    elsif checker.stalemate?
      print 'STALEMATE! '
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
