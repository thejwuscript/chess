class EnPassantChecker
  attr_accessor :finding
  attr_reader :board, :pawn, :target_ary, :game
  
  def initialize(board, pawn, target_ary, game)
    @board = board
    @pawn = pawn
    @target_ary = target_ary
    @game = game
    @finding = nil
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
    enemy_piece.en_passantable?(enemy_color, game) unless enemy_piece.nil?
  end

  def update_finding
  end
end