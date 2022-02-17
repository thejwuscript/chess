#frozen_string_literal: true

require_relative 'converter'
require_relative 'en_passant_checker'
require_relative 'castling_checker'
require_relative 'game_status_checker'

class MoveExaminer
  include Converter
  attr_accessor :board, :piece, :target, :start_ary, :target_ary, :game
  attr_accessor :en_passant_verified, :castling_verified, :double_step_verified
  
  def initialize(board = nil, piece = nil, target = nil, game = nil)
    @board = board
    @piece = piece
    @target = target
    @game = game
    @start_ary = position_to_array(piece.position) unless piece.nil?
    @target_ary = position_to_array(target) unless target.nil?
    @en_passant_verified = false
    @castling_verified = false
    @double_step_verified = false
  end

  def validate_move
    return if board.same_color_at?(target, piece) || !(search_target)
    
    if piece.is_a?(King)
      self_king_exposed? ? nil : target
    else
      ally_king_exposed? ? nil : target 
    end
  end

  def ally_king_exposed?
    color = piece.color
    original_piece = piece
    original_target = target
    original_piece_at_target = board.piece_at(target)
    board.move_piece_to_target(target, piece)
    pawn = board.remove_pawn_captured_en_passant(piece, target) if en_passant_verified
    
    self.target = board.find_own_king(color).position
    self.target_ary = position_to_array(target)
    answer = board.all_enemies(piece.color).any? do |enemy| 
      self.piece = enemy
      self.start_ary = position_to_array(enemy.position)
      search_target
    end
    self.target = original_target
    board.set_piece_at(target, original_piece_at_target)
    board.set_piece_at(original_piece.position, original_piece)
    board.set_piece_at(pawn.position, pawn) if en_passant_verified

    self.piece = original_piece
    self.target = original_target
    answer
  end

  def self_king_exposed?
    king = piece
    removed_piece = board.piece_at(target)
    board.move_piece_to_target(target, king)
    answer = board.all_enemies(piece.color).any? do |enemy|
      self.piece = enemy
      self.start_ary = position_to_array(enemy.position)
      search_target
    end
    board.set_piece_at(target, removed_piece)
    board.set_piece_at(king.position, king)
    answer
  end

  def depth_search
    manners = piece.move_manner
    for i in 0..manners.size - 1 do
      return target if recursive_search(start_ary, manners[i], target_ary)
    end
    nil
  end

  def recursive_search(start, manner, goal)
    next_ary = start.zip(manner).map { |a, b| a + b }
    return unless board.within_limits?(next_ary)
    return goal if next_ary == goal
    
    board.occupied?(next_ary) ? nil : recursive_search(next_ary, manner, goal)
  end

  def breadth_search
    manners = piece.move_manner
    until manners.empty? do
      next_ary = start_ary.zip(manners.shift).map { |a, b| a + b }
      next unless board.within_limits?(next_ary)
      return target_ary if next_ary == target_ary
    end
    nil
  end

  def pawn_move_search
    row, column = start_ary
    modifier = piece.color.eql?('W') ? -1 : 1
    one_step = [row + modifier, column]
    return if board.occupied?(one_step) || board.occupied?(target_ary)
    
    if double_step? || one_step.eql?(target_ary)
      target_ary
    end
  end

  def double_step?
    return if piece.move_count > 0

    a, b = start_ary
    self.double_step_verified = true if piece.color == 'W' && [a-2, b] == target_ary || piece.color == 'B' && [a+2, b] == target_ary
  end

  def pawn_attack_search
    modifier = piece.color.eql?('W') ? -1 : 1
    return unless start_ary.zip(target_ary).map { |a, b| ( a - b ).abs }.eql?([1, 1])   
    return unless (target_ary[0] - start_ary[0]) == modifier
    
    board.occupied?(target_ary) ?  target_ary : check_en_passant
  end

  def check_en_passant
    checker = EnPassantChecker.new(board, piece, target_ary, game)
    if checker.validate_capture_condition == true
      self.en_passant_verified = true
      target_ary
    else
      nil
    end
  end

  def king_search
    two_steps = start_ary.zip(target_ary).map { |a, b| (a - b).abs } == [0, 2]
    two_steps && piece.move_count == 0 ? validate_castling : breadth_search
  end

  def validate_castling
    checker = CastlingChecker.new(board, piece, target_ary)
    if checker.meet_castling_condition?
      self.castling_verified = true
      target_ary
    end
  end

  def search_target
    case piece
    when Rook, Bishop, Queen
      depth_search
    when Knight
      breadth_search
    when King
      king_search
    when Pawn
      pawn_attack_search || pawn_move_search
    end
  end
end
