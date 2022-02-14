class Player
  attr_accessor :name, :color, :piece_selected, :examiner_with_target
  attr_reader :board, :game

  def initialize(name, color, board, game)
    @name = name
    @color = color
    @board = board
    @game = game
    @piece_selected = nil
    @examiner_with_target = nil
  end
end