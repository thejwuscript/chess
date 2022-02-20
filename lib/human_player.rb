# frozen_string_literal: true

require_relative 'save_and_load'

class HumanPlayer < Player
  include GameMessage
  include SaveAndLoad

  def initialize(name = nil, color = nil, board)
    super
  end

  def human_move(game)
    piece = select_piece(game)
    game.save_board_info
    board.show_color_guides_after_selection(piece, self, turn)
    move_piece(piece, game)
  end

  def select_piece(game)
    position = player_selection(game)
    board.piece_at(position)
  end

  def move_piece(piece, game)
    examiner = player_target(piece,game)
    finalize_move(examiner.piece, examiner)
  end

  def player_selection(game)
    choose_piece_message(self)
    loop do
      input = player_input
      next game.save_game if input == 'S'
      next invalid_input_message if input == 'B'
      game.exit_game if input == 'Q'
      
      piece = board.piece_at(input)
      next invalid_input_message if piece.nil?      
      return input if piece.color == color && piece.moves_available?(board, turn)

      invalid_input_message
    end
  end

  def undo_selection(piece, game)
    hash = game.load_board_info
    piece.update_selected_value(false)
    board.grid = hash["grid"]
    board.origin_ary = hash["origin_ary"]
    board.attacking_arrays = hash['attacking_arrays']
    board.show_board
    piece = select_piece(game)
    board.show_color_guides_after_selection(piece, self, turn)
    player_target(piece, game)
  end

  def player_input
    loop do
      input = gets.chomp.upcase
      return input if input.match?(/^[A-H][1-8]$|^B$|^S$|^Q$/)

      invalid_input_message
      rescue ArgumentError
        invalid_input_message
    end
  end

  def player_target(piece, game)
    choose_move_message(piece)
    loop do
      target = player_input
      return undo_selection(piece, game) if target == 'B'
      exit_game if target == 'Q'
      
      next invalid_input_message if target == 'S' || board.same_color_at?(target, piece)
      
      examiner = MoveExaminer.new(board, piece, target, turn)
      move_validated = examiner.validate_move
      return examiner if move_validated

      invalid_input_message
    end
  end

  def promotion_choice
    promotion_message
    loop do
      input = gets.chomp
      return input.to_i if input.match?(/^[1-4]$/)
  
      invalid_input_message
    end
  end
end
