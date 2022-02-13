# frozen_string_literal: true

require_relative 'move_examiner'
require_relative '../lib/game_message'
require_relative '../lib/save_and_load'
require 'yaml'

class Game
  include GameMessage
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

  def play
    puts "Welcome to CHESS."
    the_game
  end

  def the_game
    load_saved_file ? load_from_yaml : pregame
    round
    game_end
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
  
      move_piece
      promote_pawn
    end
  end

  def update_turn_count
    self.turn_count += 1
  end

  def change_player
   self.current_player = turn_count.odd? ? player_white : player_black
  end

  def move_piece
    checked_king = board.find_checked_king
    king_checked_message(checked_king) if checked_king

    player = current_player
    chosen_position = player.is_a?(Computer) ? ai_input : verify_input_one
    chosen_piece = board.piece_at(chosen_position)
    verified_move = player.is_a?(Computer) ? ai_target(chosen_piece) : choose_target(chosen_piece)
    finalize_move(chosen_piece, verified_move)
  end

  def choose_target(chosen_piece)
    choose_move_message(chosen_piece)
    loop do
      target = player_input
      next invalid_input_message if board.same_color_at?(target, chosen_piece)
      
      verified_move = board.validate_move(chosen_piece, target, self)
      return verified_move if verified_move

      invalid_input_message
    end
  end

  def finalize_move(piece, target)
    king_follow_through(piece, target) if piece.is_a?(King)
    pawn_follow_through(piece, target) if piece.is_a?(Pawn)
    
    board.set_piece_at(target, piece)
    board.delete_piece_at(piece.position)
    piece.position = target
    piece.move_count += 1
  end

  def king_follow_through(king, target)
    board.move_castle(target) if board.castling?(king, target)
  end

  def pawn_follow_through(pawn, target)
    board.remove_pawn_captured_en_passant(pawn, target, self)
    target_ary = board.position_to_array(target)
    pawn.store_turn_count(@turn_count) if board.pawn_double_step?(pawn, target_ary)
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

  def verify_input_one
    choose_piece_message
    loop do
      input = player_input
      piece = board.piece_at(input)
      current_color = current_player.color
      next invalid_input_message if piece.nil?
      return input if piece.color == current_color && moves_available?(piece)

      invalid_input_message
    end
  end

  def game_over?
    checker = GameStatusChecker.new(current_player.color, board, self)
    if checker.stalemate?
      true
    elsif checker.checkmate?
      players = [player_white, player_black]
      self.winner = players.find { |player| player != current_player }
      true
    else false
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

  def ai_input
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
