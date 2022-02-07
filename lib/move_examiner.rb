#frozen_string_literal: true

require_relative '../lib/converter'

class MoveExaminer
  include Converter
  attr_accessor :board, :piece, :target, :color

  def initialize
    @board = nil
    @piece = nil
    @target_ary = nil
    @color = nil
  end
  
  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

  def depth_search(start, manner, target_ary)
    next_ary = start.zip(manner).map { |a, b| a + b }
    return unless within_limits?(next_ary)
    return target_ary if next_ary == target_ary
    
    board.occupied?(next_ary) ? nil : depth_search(next_ary, manner, target_ary)
  end

  def breadth_search(start, manners, target_ary)
    until manners.empty? do
      next_ary = start.zip(manners.shift).map { |a, b| a + b }
      next unless within_limits?(next_ary)
      return target_ary if next_ary == target_ary
    end
  end

  def pawn_move_search(pawn, target_ary)
    row, column = position_to_array(pawn.position)
    modifier = pawn.color.eql?('W') ? -1 : 1
    one_step = [row + modifier, column]
    return if board.occupied?(one_step) || board.occupied?(target_ary)
    
    pawn.possible_moves.include?(target_ary) ? target_ary : nil
  end
end
