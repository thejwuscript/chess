#frozen_string_literal: true

require_relative '../lib/converter'

class MoveExaminer
  include Converter
  attr_reader :board, :piece, :target, :color, :start_ary, :target_ary

  def initialize(board = nil, piece = nil, target = nil, color = nil)
    @board = board
    @piece = piece
    @target = target
    @color = color
    @start_ary = position_to_array(piece.position)
    @target_ary = position_to_array(target)
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
    
    piece.possible_moves.include?(target_ary) ? target_ary : nil
  end

  def search_target
    case piece
    when Rook || Bishop || Queen
      depth_search
    when Knight || King
      breadth_search
    when Pawn
      pawn_move_search # || pawn_attack
    end
  end

end
