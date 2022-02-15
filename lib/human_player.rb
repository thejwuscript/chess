# frozen_string_literal: true

require_relative 'save_and_load'

class HumanPlayer < Player
  include GameMessage
  include SaveAndLoad

  def initialize(name = nil, color = nil, board, game)
    super
  end

  def player_selection
    choose_piece_message(self.name)
    loop do
      input = player_input
      piece = board.piece_at(input)
      next invalid_input_message if piece.nil?
      
      return input if piece.color == color && piece.moves_available?(board, game)

      invalid_input_message
    end
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

  def player_target(piece)
    choose_move_message(piece)
    loop do
      target = player_input
      next invalid_input_message if board.same_color_at?(target, piece)
      
      examiner = MoveExaminer.new(board, piece, target, game)
      move_validated = examiner.validate_move
      return examiner if move_validated

      invalid_input_message
    end
  end
end
