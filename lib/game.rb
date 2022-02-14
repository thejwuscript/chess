# frozen_string_literal: true

require_relative 'move_examiner'
require_relative '../lib/game_message'
require_relative '../lib/save_and_load'
require 'yaml'
require_relative 'converter'

class Game
  include GameMessage
  include SaveAndLoad
  include Converter

  attr_accessor :board, :turn_count, :current_player, :player_white, :player_black, :winner
  
  def initialize
    @board = Board.new
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
    load_saved_file ? load_from_yaml : pregame
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
    self.player_white = Player.new(names.first, 'W')
    self.player_black = Player.new(names.last, 'B')
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
    get_name_message { 'one' }
    player_one_name = gets.chomp
    players = [Player.new(player_one_name), Computer.new].shuffle
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
      move_piece(select_piece)
      #promote_pawn
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

  def select_piece
    player = current_player
    position = player.is_a?(Computer) ? ai_selection : human_selection
    board.piece_at(position)
  end

  def move_piece(piece)
    player = current_player
    examiner = player.is_a?(Computer) ? ai_target(piece) : human_target(piece)
    finalize_move(piece, examiner)
  end

  def human_target(chosen_piece)
    choose_move_message(chosen_piece)
    loop do
      target = player_input
      next invalid_input_message if board.same_color_at?(target, chosen_piece)
      
      examiner = MoveExaminer.new(board, chosen_piece, target, self)
      move_validated = examiner.validate_move
      return examiner if move_validated

      invalid_input_message
    end
  end

  def finalize_move(piece, examiner)
    king_follow_through(piece, examiner) if piece.is_a?(King)
    pawn_follow_through(piece, examiner) if piece.is_a?(Pawn)

    target = examiner.target
    board.set_piece_at(target, piece)
    board.delete_piece_at(piece.position)
    piece.position = target
    piece.move_count += 1
  end

  def king_follow_through(king, examiner)
    #board.move_castle(target) if board.castling?(king, target)
  end

  def pawn_follow_through(pawn, examiner)
    board.remove_pawn_captured_en_passant(pawn, examiner.target) if examiner.en_passant_verified
    pawn.store_turn_count(turn_count) if examiner.double_step_verified
  end


  def player_input
    loop do
      input = gets.chomp.upcase
      next save_game if input == 'S'
      return input if input.match?(/^[A-H][1-8]$/)

      invalid_input_message
      rescue ArgumentError
        invalid_input_message
    end
  end

  def human_selection
    choose_piece_message
    loop do
      input = player_input
      piece = board.piece_at(input)
      color = current_player.color
      next invalid_input_message if piece.nil?
      
      return input if piece.color == color && piece.moves_available?(board, self)

      invalid_input_message
    end
  end

  def game_over?
    checker = GameStatusChecker.new(current_player.color, board, self)
    #if checker.stalemate?
      #true
    if checker.checkmate?
      self.winner = current_player.color == 'W' ? player_black : player_white
      true
    else 
      false
    end
  end

  def promote_pawn
    pawn = board.promotion_candidate
    return if pawn.nil?

    number = promotion_choice
    piece = [Queen, Rook, Bishop, Knight][number - 1].new(pawn.color, pawn.position)
    piece.assign_symbol
    board.set_piece_at(piece.position, piece)
  end

  def promotion_choice
    promotion_message
    loop do
      input = gets.chomp
      return input.to_i if input.match?(/^[1-4]$/)
  
      invalid_input_message
    end
  end

  def conclusion
    winner ? declare_winner : declare_draw
  end

  def ai_selection
    color = current_player.color
    valid_pieces = board.all_allies(color).keep_if { |piece| moves_available?(piece) }.shuffle
    valid_pieces.each do |ally|
      board.grid.flatten.compact.shuffle.each do |piece|
        return ally.position if board.validate_move(ally, piece.position, self)
  
      end
    end
    valid_pieces.sample.position
  end

  def ai_target(piece)
    array = []
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    validated = array.keep_if { |position| board.validate_move(piece, position, self) }
    validated.find { |position| board.piece_at(position) } || validated.sample
  end
end
