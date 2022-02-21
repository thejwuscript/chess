# frozen_string_literal: true

require_relative '../lib/move_examiner'

class GameStatusChecker
  attr_reader :color, :board, :turn

  def initialize(color, board, turn = nil)
    @color = color
    @board = board
    @turn = turn
  end

  def no_legal_moves?
    board.all_allies(color).none? { |piece| piece.moves_available?(board, turn) }
  end

  def own_king_in_check?(king_moving_position = nil)
    board.enemies_giving_check(color, king_moving_position).any?
  end

  def no_counterattack?
    enemy_positions = board.enemies_giving_check(color).map { |enemy| enemy.position }
    array = board.all_allies(color).flat_map do |ally|
      enemy_positions.filter_map { |pos| MoveExaminer.new(board, ally, pos, turn).validate_move }
    end
    array.empty?
  end

  def stalemate?
    no_legal_moves? && no_counterattack? && !(own_king_in_check?)
  end

  def checkmate?
    no_legal_moves? && no_counterattack? && own_king_in_check?
  end
end