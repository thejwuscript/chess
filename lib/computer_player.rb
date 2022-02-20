# frozen_string_literal: true

require_relative 'player'
require_relative 'game_message'

class ComputerPlayer < Player
  include GameMessage
  attr_reader :board

  def initialize(name, color = nil, board)
    super(name, color)
    @board = board
  end

  def valid_pieces(turn)
     board.all_allies(color).keep_if { |piece| piece.moves_available?(board, turn) }.shuffle
  end

  def all_possible_targets(turn)
    valid_pieces(turn).each_with_object({}) do |piece, hash|
      hash[piece] = piece.possible_targets
    end
  end

  def validated_examiners(turn)
    all_possible_targets(turn).each_with_object([]) do | (piece, targets), array |
      targets.each do |target|
        examiner = MoveExaminer.new(board, piece, target, turn)
        array << examiner if examiner.validate_move
      end
    end
  end

  def choose_examiner(turn)
    examiners = validated_examiners(turn)
    examiners.each do |examiner|
      return examiner if examiner.en_passant_verified
      
    end
    alternative = examiners.find { |examiner| board.piece_at(examiner.target) }
    alternative.nil? ? examiners.sample : alternative
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
