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

  def depth_search(start, manner, goal)
    next_ary = start.zip(manner).map { |a, b| a + b }
    return unless within_limits?(next_ary)
    return goal if next_ary == goal
    
    board.occupied?(next_ary) ? nil : depth_search(next_ary, manner, goal)
  end

  def breadth_search(start, manners, goal)
    until manners.empty? do
      next_ary = start.zip(manners.shift).map { |a, b| a + b }
      next unless within_limits?(next_ary)
      return goal if next_ary == goal
    end
  end

  def pawn_move_search(pawn, goal)
    row, column = start_ary
    modifier = pawn.color.eql?('W') ? -1 : 1
    one_step = [row + modifier, column]
    return if board.occupied?(one_step) || board.occupied?(goal)
    
    pawn.possible_moves.include?(goal) ? goal : nil
  end

  def search_target
    piece.search_method(start_ary, target_ary)
  end
end
