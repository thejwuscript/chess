# frozen_string_literal: true

require_relative '../lib/movement'
require_relative '../lib/converter'

class Board
  include Movement
  include Converter
  
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
    puts ''
    grid.each_with_index do |row, row_index|
      numbers_column(row_index)
      row_index.even? ? white_black_row(row) : black_white_row(row)
    end
    letter_coordinates
  end

  def delete_piece_at(position)
    row, column = position_to_array(position)
    grid[row][column] = nil
  end

  def find_checked_king
    kings = grid.flatten.keep_if { |piece| piece.is_a? King }
    kings.each { |king| return king if checked?(king, king.position) }
    nil
  end

  def promote_candidate
    array = grid[0] + grid[7]
    array.detect { |piece| piece.is_a? Pawn }
  end

  def occupied?(array)
    row, column = array
    grid[row][column] ? true : false
  end

  private
  
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
    piece.nil? ? "\e[48;5;245m   \e[0m" : "\e[48;5;245m #{piece.symbol} \e[0m"
  end

  def black_square(piece)
    piece.nil? ? "\e[48;5;237m   \e[0m" : "\e[48;5;237m #{piece.symbol} \e[0m"
  end

  def letter_coordinates
    puts "     #{('a'..'h').to_a.join('  ')}"
  end

  def numbers_column(index)
    numbers = (1..8).to_a.reverse
    print "  #{numbers[index]} "
  end
end
