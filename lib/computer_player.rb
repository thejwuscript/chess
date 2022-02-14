# frozen_string_literal: true

class ComputerPlayer < Player

  def initialize(name, color = nil, board, game)
    super
  end

  def player_selection
    valid_pieces = board.all_allies(color).keep_if { |piece| piece.moves_available?(board, game) }.shuffle
    valid_pieces.each do |ally|
      board.grid.flatten.compact.shuffle.each do |piece|
        return ally.position if MoveExaminer.new(board, ally, piece.position, game).validate_move
  
      end
    end
    valid_pieces.sample.position
  end

  def player_target(piece)
    array = []
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    validated = array.map do |position|
      examiner = MoveExaminer.new(board, piece, position, game)
      examiner.validate_move ? examiner : nil
    end
    validated.compact.find { |obj| board.piece_at(obj.target) } || validated.compact.sample
  end
end
