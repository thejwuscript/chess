# frozen_string_literal: true

class Board
  attr_accessor :grid

  PROMOTED_BLACK_PIECES = %w[♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜]
  BLACK_PAWN = '♟︎'
  PROMOTED_WHITE_PIECES = %w[♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖]
  WHITE_PAWN = '♙'
  
  def initialize
    @grid = Array.new(8) {Array.new(8, ' ')}
    initial_pieces_order
  end

  def initial_pieces_order
    grid[0] = PROMOTED_BLACK_PIECES
    grid[1].map! { |item| BLACK_PAWN }
    grid[6].map! { |item| WHITE_PAWN }
    grid[7] = PROMOTED_WHITE_PIECES
  end

  def show_board
    grid.each_with_index do |row, row_index|
      row_index.even? ? white_black_row(row) : black_white_row(row)
    end
  end

  def white_black_row(row)
    row.each_with_index do |item, ind|
      print ind.even? ? "\e[48;5;251m #{item} \e[0m" : "\e[48;5;240m #{item} \e[0m"
    end
    print "\n"
  end
  
  def black_white_row(row)
    row.each_with_index do |item, ind|
      print ind.even? ? "\e[48;5;240m #{item} \e[0m" : "\e[48;5;251m #{item} \e[0m"
    end
    print "\n"
  end
end
