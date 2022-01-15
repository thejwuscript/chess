# frozen_string_literal: true

class Board
  attr_accessor :grid
  
  LETTERS = %w(a b c d e f g h)
  
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def piece_at(input) # ex. 'c4, downcase'
    column = LETTERS.index(input[0])
    row = -input[1].to_i
    grid[row][column]
  end

  def insert_spaces
    grid.map! do |row|
      row.map! do |element|
        element.nil? ? ' ' : element
      end
    end
  end

end


PROMOTED_BLACK_PIECES = %w[♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜]
BLACK_PAWN = '♟︎'
PROMOTED_WHITE_PIECES = %w[♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖]
WHITE_PAWN = '♙'