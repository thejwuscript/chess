class EnPassantChecker
  attr_reader :board, :pawn, :target_ary, :game
  
  def initialize(board, pawn, target_ary, game)
    @board = board
    @pawn = pawn
    @target_ary = target_ary
    @game = game
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

  def validate_capture_condition
    enemy_piece = locate_enemy_pawn
    return if enemy_piece.nil?
    
    enemy_piece.en_passantable?(enemy_color, game)
  end
end