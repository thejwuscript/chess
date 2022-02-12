# frozen_string_literal: true

require_relative '../lib/move_examiner'

class GameStatusChecker
  attr_reader :color, :board, :game

  def initialize(color, board, game = nil) #game object is optional.
    @color = color
    @board = board
    @game = game
  end

  def no_legal_moves?
    board.all_allies(color).none? { |piece| piece.moves_available?(board, game) }
  end

  def own_king_in_check?
    board.enemies_giving_check(color).any?
  end

  def no_counterattack?
    enemy_positions = board.enemies_giving_check(color).map { |enemy| enemy.position }
    board.all_allies(color).each do |ally|
      enemy_positions.each do |target| 
        examiner = MoveExaminer.new(board, ally, target, game)
        return false if examiner.validate_move
        
      end
    end
    true
  end

end