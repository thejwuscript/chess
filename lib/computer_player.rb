# frozen_string_literal: true

class ComputerPlayer < Player

  def initialize(name, color = nil, board, game)
    super
  end

  def player_selection
    valid_pieces.each do |ally|
      board.grid.flatten.compact.shuffle.each do |piece|
        return ally.position if MoveExaminer.new(board, ally, piece.position, game).validate_move
  
      end
    end
    valid_pieces.sample.position
  end

  def valid_pieces
     board.all_allies(color).keep_if { |piece| piece.moves_available?(board, game) }.shuffle
  end

  def player_target(piece)
    array = ('A'..'H').to_a.flat_map do |letter|
      ('1'..'8').to_a.map { |number| letter + number }
    end
    validated = array.map do |position|
      examiner = MoveExaminer.new(board, piece, position, game)
      examiner.validate_move ? examiner : nil
    end
    validated.compact.find { |obj| board.piece_at(obj.target) } || validated.compact.sample
  end

  def promotion_choice
    case rand(1..100)
      when 1..97 then 1
      when 98 then 2
      when 99 then 3
      when 100 then 4
    end
  end

  def all_possible_targets
    valid_pieces.each_with_object({}) do |piece, hash|
      hash[piece] = piece.possible_targets
    end
  end

  
end
