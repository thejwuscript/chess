# frozen_string_literal: true

require_relative 'player'
require_relative 'game_message'

class ComputerPlayer < Player
  include GameMessage

  def initialize(name, color = nil, board, game)
    super
  end

  def valid_pieces
     board.all_allies(color).keep_if { |piece| piece.moves_available?(board, game) }.shuffle
  end

  def all_possible_targets
    valid_pieces.each_with_object({}) do |piece, hash|
      hash[piece] = piece.possible_targets
    end
  end

  def validated_examiners
    all_possible_targets.each_with_object([]) do | (piece, targets), array |
      targets.each do |target|
        examiner = MoveExaminer.new(board, piece, target, game)
        array << examiner if examiner.validate_move
      end
    end
  end

  def choose_examiner
    examiners = validated_examiners
    examiners.each do |examiner|
      return examiner if examiner.en_passant_verified
      
    end
    alternative = examiners.find { |examiner| board.piece_at(examiner.target) }
    alternative.nil? ? examiners.sample : alternative
  end

  def computer_move
    examiner = choose_examiner
    #computer_move_message(examiner)
    board.show_changed_board_color_indication(examiner.piece, game)
    finalize_move(examiner.piece, examiner)
  end

  def promotion_choice
    case rand(1..100)
      when 1..97 then 1
      when 98 then 2
      when 99 then 3
      when 100 then 4
    end
  end
end
