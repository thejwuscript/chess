# frozen_string_literal: true

require_relative 'converter'

class Player
  include Converter
  
  attr_accessor :name, :color, :piece_selected, :examiner_with_target
  attr_reader :board, :game

  def initialize(name, color, board, game)
    @name = name
    @color = color
    @board = board
    @game = game
  end

  def player_move
    self.is_a?(ComputerPlayer) ? computer_move : human_move
  end

  def finalize_move(piece, examiner)
    target = examiner.target
    board.show_board_with_targeted_piece(position_to_array(target), self)
    board.move_piece_to_target(target, piece)
    piece.update_attributes_after_move(target)
    king_follow_through(piece, examiner) if piece.is_a?(King)
    pawn_follow_through(piece, examiner) if piece.is_a?(Pawn)
    
    board.show_board_with_delay(self)
  end

  def king_follow_through(king, examiner)
    target = examiner.target
    board.move_castle(target) if examiner.castling_verified
  end

  def pawn_follow_through(pawn, examiner)
    board.remove_pawn_captured_en_passant(pawn, examiner.target) if examiner.en_passant_verified
    pawn.store_turn_count(game.turn_count) if examiner.double_step_verified
  end
end
