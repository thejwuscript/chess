# frozen_string_literal: true

class ComputerPlayer
  
  attr_reader :name, :board, :turn
  attr_accessor :color

  def initialize(name, board)
    @name = name
    @color = nil
    @board = board
  end

  def valid_pieces
     board.all_allies(color).keep_if { |piece| piece.moves_available?(board, turn) }.shuffle
  end

  def all_possible_targets
    valid_pieces.each_with_object({}) do |piece, hash|
      hash[piece] = piece.possible_targets
    end
  end

  def validated_examiners
    all_possible_targets.each_with_object([]) do | (piece, targets), array |
      targets.each do |target|
        examiner = MoveExaminer.new(board, piece, target, turn)
        array << examiner if examiner.validate_move
      end
    end
  end

  def choose_examiner(current_turn)
    @turn = current_turn
    examiners = validated_examiners
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
