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
    examiners.each { |examiner| return examiner if examiner.en_passant_verified || examiner.castling_verified }
    
    filtered = examiners.reject { |examiner| danger_queen?(examiner) }
    more_filtered = filtered.reject do |examiner| 
      danger_self?(examiner) if [Queen, Knight, Rook, Bishop].include?(examiner.piece.class)

    end  
    urgent = more_filtered.reject { |examiner| !(danger_now?(examiner)) } 
    captures = more_filtered.select { |examiner| board.piece_at(examiner.target) }
    promote_capture = captures.find do |examiner|
      target_class = board.piece_at(examiner.target).class
      [Queen, Rook, Bishop, Knight].include?(target_class)
    end
    promote_capture || urgent.sample || captures.sample || 
    more_filtered.sample || filtered.sample || examiners.sample
  end

  def danger_self?(examiner, mock_board = board.deep_clone)
    mock_board.move_piece_to_target(examiner.target, examiner.piece)
    mock_board.all_enemies(self.color).any? do |enemy| 
      MoveExaminer.new(mock_board, enemy, examiner.target).validate_move
    end
  end

  def danger_queen?(examiner, mock_board = board.deep_clone)
    return if examiner.piece.is_a?(Queen)
    
    mock_board.move_piece_to_target(examiner.target, examiner.piece)
    queen = mock_board.grid.flatten.compact.find { |piece| piece.color == self.color && piece.is_a?(Queen) }
    return if queen.nil?
    
    mock_board.all_enemies(self.color).any? do |enemy|
      MoveExaminer.new(mock_board, enemy, queen.position).validate_move
    end
  end

  def danger_now?(examiner, mock_board = board.deep_clone)
    return if examiner.piece.is_a?(Pawn)
    
    mock_board.all_enemies(self.color).any? do |enemy|
      MoveExaminer.new(mock_board, enemy, examiner.piece.position).validate_move
    end
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
