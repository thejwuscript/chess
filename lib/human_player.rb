# frozen_string_literal: true

require_relative 'save_and_load'

class HumanPlayer < Player
  include GameMessage
  include SaveAndLoad

  def initialize(name = nil, color = nil, board, game)
    super
  end

  def human_move
    piece = select_piece
    save_board_info
    board.show_color_guides_after_selection(piece, game)
    move_piece(piece)
  end

  def select_piece
    position = player_selection
    board.piece_at(position)
  end

  def move_piece(piece)
    examiner = player_target(piece)
    finalize_move(examiner.piece, examiner)
  end

  def player_selection
    choose_piece_message(self)
    loop do
      input = player_input
      next save_game if input == 'S'
      next invalid_input_message if input == 'B'
      game.exit_game if input == 'Q'
      
      piece = board.piece_at(input)
      next invalid_input_message if piece.nil?      
      return input if piece.color == color && piece.moves_available?(board, game)

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
    piece = select_piece
    board.show_changed_board_color_indication(piece, game)
    player_target(piece)
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

  def player_target(piece)
    choose_move_message(piece)
    loop do
      target = player_input
      return undo_selection(piece) if target == 'B'
      game.exit_game if target == 'Q'
      
      next invalid_input_message if target == 'S' || board.same_color_at?(target, piece)
      
      examiner = MoveExaminer.new(board, piece, target, game)
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
