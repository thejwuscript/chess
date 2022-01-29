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
    number = choose_game_format
    number == 1 ? assign_ai_player : assign_players
    show_player_assignment
    prep_board
  end

  def assign_ai_player
    get_name_message { 'one' }
    player_one_name = gets.chomp
    players = [Player.new(player_one_name), Computer.new].shuffle
    self.player_black = players.pop
    self.player_white = players.pop
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
      update_turn_counts
      change_player
      return if game_over?
  
      move_piece
      promote_pawn
    end
  end

  def update_turn_counts
    self.turn_count += 1
    board.grid.flatten.compact.each { |piece| piece.turn_count += 1 }
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
      
      verified_move = board.validate_move(chosen_piece, target)
      return verified_move if verified_move

      invalid_input_message
    end
  end

  #def move_king(king)
  #  king_checked_message(king)
  #  verified_move = choose_target(king)
  #  finalize_move(king, verified_move)
  #end

  def finalize_move(piece, target)
    # move_castle if board.castling?(piece, target)
    board.delete_en_passant(piece, target)
    board.set_piece_at(target, piece)
    board.delete_piece_at(piece.position)
    piece.position = target
    piece.move_count += 1
  end

  def player_input
    loop do
      input = gets.chomp.upcase
      return input if input.match?(/^[A-H][1-8]$/)
  
      invalid_input_message
    end
  end

  def verify_input_one
    choose_piece_message
    loop do
      input = player_input #or computer input
      piece = board.piece_at(input)
      current_color = current_player.color
      next invalid_input_message if piece.nil?
      return input if piece.color == current_color && moves_available?(piece)

      invalid_input_message
    end
  end

  def moves_available?(piece)
    array = []
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    array.any? { |move| board.validate_move(piece, move) }
  end

  def game_over?
    king = board.find_checked_king
    return false if king.nil?
    return true if board.stalemate?(king)

    if board.checkmate?(king)
      self.winner = king.color == 'W' ? player_black : player_white
      true
    end
  end

  def promote_pawn
    pawn = board.promote_candidate
    return if pawn.nil?

    number = promotion_choice
    piece = [Queen, Rook, Bishop, Knight][number - 1].new(pawn.color, pawn.position)
    piece.assign_symbol
    # set piece's turn count
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

  def game_end
    winner ? declare_winner : declare_draw
    play_again?
  end

  def play_again?
  end

  def ai_input
    color = current_player.color
    valid_pieces = board.all_allies(color).keep_if { |piece| moves_available?(piece) }.shuffle
    valid_pieces.each do |ally|
      board.grid.flatten.compact.shuffle.each do |piece|
        return ally.position if board.validate_move(ally, piece.position)
     # piece.possible_moves.each do |move|
     #   next if board.same_color_at?(move, piece)
     #   return piece.position if board.piece_at(move) && board.validate_move(piece, move)
     #   
     end
    end
    valid_pieces.sample.position
  end

  def ai_target(piece)
    array = []
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    validated = array.keep_if { |position| board.validate_move(piece, position) }.shuffle
    validated.find { |position| board.piece_at(position) } || validated.sample
  end
end
