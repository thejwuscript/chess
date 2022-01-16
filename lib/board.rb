# frozen_string_literal: true

class Board
  attr_reader :grid
  
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def piece_at(position) # UPPERCASE
    row, column = position_to_array(position)
    grid[row][column]
  end

  def set_piece_at(position, piece)
    row, column = position_to_array(position)
    grid[row][column] = piece
  end

  def show_board
    grid_with_spaces.each_with_index do |row, row_index|
      row_index.even? ? white_black_row(row) : black_white_row(row)
    end
  end

  def grid_with_spaces
    grid.map do |row|
      row.map do |element|
        element.nil? ? ' ' : element
      end
    end
  end
  
  private

  def position_to_array(position)
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
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

  def white_square(piece)
    if piece == ' '
      "\e[48;5;251m #{piece} \e[0m"
    else
      "\e[48;5;251m #{piece.symbol} \e[0m"
    end
  end

  def black_square(piece)
    if piece == ' '
      "\e[48;5;240m #{piece} \e[0m"
    else
      "\e[48;5;240m #{piece.symbol} \e[0m"
    end
  end

end

# PROMOTED_BLACK_PIECES = %w[♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜]
# BLACK_PAWN = '♟︎'
# PROMOTED_WHITE_PIECES = %w[♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖]
# WHITE_PAWN = '♙'