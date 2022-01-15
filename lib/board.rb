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

  def grid_with_spaces
    grid.map do |row|
      row.map do |element|
        element.nil? ? ' ' : element
      end
    end
  end

  def show_board
    grid_with_spaces.each_with_index do |row, row_index|
      row_index.even? ? white_black_row(row) : black_white_row(row)
    end
  end

  def white_black_row(row)
    row.each_with_index do |piece, column|
      print column.even? ? white_square(piece) : black_square(piece)
    end
    print "\n"
  end
  
  def black_white_row(row)
    row.each_with_index do |piece, column|
      print column.even? ? black_square(piece) : white_square(piece)
    end
    print "\n"
  end

  def white_square(obj)
    "\e[48;5;251m #{obj} \e[0m"
  end

  def black_square(obj)
    "\e[48;5;240m #{obj} \e[0m"
  end

end

# PROMOTED_BLACK_PIECES = %w[♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜]
# BLACK_PAWN = '♟︎'
# PROMOTED_WHITE_PIECES = %w[♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖]
# WHITE_PAWN = '♙'