# frozen_string_literal: true

class ComputerPlayer
  
  attr_reader :name, :board, :turn
  attr_accessor :color

  def initialize(name, board)
    @name = name
    @color = nil
    @board = board
  end

  def choose_examiner(current_turn, num = rand(1..10))
    @turn = current_turn
    examiners = validated_examiners
    full_attack = examiners.select { |examiner| board.piece_at(examiner.target) }
    not_sacrificing_queen = remove_moves_exposing_queen(examiners)
    not_sacrificing_self_and_queen = remove_moves_exposing_self(not_sacrificing_queen)
    attack_king = moves_attacking_king(not_sacrificing_self_and_queen)
    capturing_moves = not_sacrificing_self_and_queen.select { |examiner| board.piece_at(examiner.target) }
    run_from_enemy_capture = capturing_moves.find { |examiner| danger_now?(examiner) } ||
    not_sacrificing_self_and_queen.find { |examiner| danger_now?(examiner) }
    promote_capture = enemy_promotes_targeted(capturing_moves)
    special_moves(examiners).sample || promote_capture || (run_from_enemy_capture if num > 1) ||
    (capturing_moves.sample if num > 1) || (attack_king.sample if num > 3) ||
    (not_sacrificing_self_and_queen.sample if num > 1) || (not_sacrificing_queen.sample if queen_alive?) ||
    full_attack.sample || examiners.sample
  end

  def promotion_choice
    case rand(1..100)
      when 1..97 then 1
      when 98 then 2
      when 99 then 3
      when 100 then 4
    end
  end

  def valid_pieces
     board.all_allies(color).keep_if { |piece| piece.moves_available?(board, turn) }.shuffle
  end

  def all_possible_targets
    valid_pieces.each_with_object({}) do |piece, hash|
      hash[piece] = piece.possible_targets(board)
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

  def danger_self?(examiner, mock_board = board.deep_clone)
    mock_board.move_piece_to_target(examiner.target, examiner.piece)
    mock_board.all_enemies(self.color).any? do |enemy| 
      MoveExaminer.new(mock_board, enemy, examiner.target).validate_move
    end
  end

  def queen_alive?
    board.grid.flatten.compact.find { |piece| piece.color == self.color && piece.is_a?(Queen) }
  end

  def danger_queen?(examiner, mock_board = board.deep_clone)
    #return danger_self?(examiner) if examiner.piece.is_a?(Queen)
    
    mock_board.move_piece_to_target(examiner.target, examiner.piece)
    if examiner.piece.is_a?(Queen)
      enemy_target = examiner.target
    else
      queen = mock_board.grid.flatten.compact.find { |piece| piece.color == self.color && piece.is_a?(Queen) }
      return if queen.nil?

      enemy_target = queen.position
    end
    
    mock_board.all_enemies(self.color).any? do |enemy|
      MoveExaminer.new(mock_board, enemy, enemy_target).validate_move
    end
  end

  def danger_now?(examiner, mock_board = board.deep_clone)
    return if examiner.piece.is_a?(Pawn)
    
    mock_board.all_enemies(self.color).any? do |enemy|
      MoveExaminer.new(mock_board, enemy, examiner.piece.position).validate_move
    end
  end

  def special_moves(examiners)
    examiners.select { |examiner| examiner.en_passant_verified || examiner.castling_verified }
  end

  def remove_moves_exposing_queen(examiners_list)
    examiners_list.reject { |examiner| danger_queen?(examiner) }
  end

  def remove_moves_exposing_self(examiners_list)
    examiners_list.reject do |examiner|
      klass = examiner.piece.class
      [Queen, Knight, Rook, Bishop].include?(klass) ? danger_self?(examiner) : next
    end
  end

  def moves_attacking_king(examiners_list)
    examiners_list.select do |examiner|
      test_board = board.deep_clone
      king = test_board.find_enemy_king(self.color)
      ally = test_board.piece_at(examiner.piece.position)
      test_board.move_piece_to_target(examiner.target, ally)
      ally.position = examiner.target
      MoveExaminer.new(test_board, ally, king.position, turn).search_target
    end
  end

  def enemy_promotes_targeted(examiners_list)
    examiners_list.find do |examiner|
      target_class = board.piece_at(examiner.target).class
      [Queen, Rook, Bishop, Knight].include?(target_class)
    end
  end
end
