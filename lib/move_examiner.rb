#frozen_string_literal: true

require_relative 'converter'
require_relative 'en_passant_checker'
require_relative 'castling_checker'
require_relative 'game_status_checker'

class MoveExaminer
  include Converter
  attr_reader :board, :piece, :target, :color, :start_ary, :target_ary, :game
  attr_accessor :en_passant, :castling
  
  def initialize(board = nil, piece = nil, target = nil, game = nil)
    @board = board
    @piece = piece
    @target = target
    @game = game
    @start_ary = position_to_array(piece.position) unless piece.nil?
    @target_ary = position_to_array(target) unless target.nil?
    @en_passant = false
    @castling = false
  end

  def validate_move
    return if board.same_color_at?(target, piece) || !(search_target)
    
    own_king_exposed? ? nil : target
  end

  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

  def depth_search
    manners = piece.move_manner
    for i in manners.size - 1 do
      return target if recursive_search(start_ary, manners[i], target_ary)
    end
  end

  def recursive_search(start, manner, goal)
    next_ary = start.zip(manner).map { |a, b| a + b }
    return unless within_limits?(next_ary)
    return goal if next_ary == goal
    
    board.occupied?(next_ary) ? nil : recursive_search(next_ary, manner, goal)
  end

  def breadth_search
    manners = piece.move_manner
    until manners.empty? do
      next_ary = start_ary.zip(manners.shift).map { |a, b| a + b }
      next unless within_limits?(next_ary)
      return target_ary if next_ary == target_ary
    end
  end

  def pawn_move_search
    row, column = start_ary
    modifier = piece.color.eql?('W') ? -1 : 1
    one_step = [row + modifier, column]
    return if board.occupied?(one_step) || board.occupied?(target_ary)
    
    target_ary if double_step? || one_step.eql?(target_ary)
  end

  def double_step?
    return if piece.move_count > 0

    a, b = start_ary
    if piece.color == 'W' && [a-2, b] == target_ary || piece.color == 'B' && [a+2, b] == target_ary
      piece.store_turn_count(game.turn_count)
      true
    end
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
      self.en_passant = true; target_ary
    end
  end

  def king_search
    two_steps = start_ary.zip(target_ary).map { |a, b| (a - b).abs } == [0, 2]
    two_steps && piece.move_count == 0 ? validate_castling : breadth_search
  end

  def validate_castling
    checker = CastlingChecker.new(board, piece, target_ary)
    if checker.meet_castling_condition?
      self.castling = true; target_ary
    end
  end

  def own_king_exposed?
    board.move_piece_to_target(target, piece)
    board.remove_pawn_captured_en_passant(piece, target, game) if en_passant
    
    board.find_own_king_in_check(piece.color) ? true : false
  end

  def search_target
    case piece
    when Rook || Bishop || Queen
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
