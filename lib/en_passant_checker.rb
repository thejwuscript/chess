class EnPassantChecker
  attr_reader :board, :pawn, :target_ary, :turn
  
  def initialize(board, pawn, target_ary, turn)
    @board = board
    @pawn = pawn
    @target_ary = target_ary
    @turn = turn
  end

  def enemy_color
    pawn.color == 'W' ? 'B' : 'W'
  end

  def locate_enemy_pawn
    row, column = target_ary
    modifier = pawn.color == 'W' ? 1 : -1
    piece = board.grid[row + modifier][column]
    piece if piece.is_a?(Pawn) && piece.color != pawn.color
  end

  def valid_capture_condition?
    enemy_piece = locate_enemy_pawn
    enemy_piece.en_passantable?(enemy_color, turn) if enemy_piece
  end
end
