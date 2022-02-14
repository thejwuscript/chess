#frozen_string_literal: true

require_relative 'move_examiner'

class Piece
  attr_accessor :position, :color, :symbol, :type, :turn_count, :move_count

  def initialize(color, position)
    @color = color
    @position = position
    @symbol = assign_symbol
    @turn_count = 0
    @move_count = 0
  end

  def position_to_array
    row = (1..8).to_a.reverse.index(position[1].to_i)
    column = ('A'..'Z').to_a.index(position[0])
    [row, column]
  end

  def array_to_position(array)
    letter = ('A'..'Z').to_a[array.last]
    number = (1..8).to_a.reverse[array.first]
    "#{letter}#{number}"
  end
  
  def within_limits?(array)
    array.all? { |num| num.between?(0, 7) }
  end

  def possible_move_arrays
    unfiltered = move_manner.map do |manner| 
      position_to_array.zip(manner).map { |a, b| a + b }
    end
    unfiltered.keep_if { |item| within_limits?(item) }
  end

  def possible_moves
    possible_move_arrays.map { |array| array_to_position(array) }
  end

  def all_squares(array = [])
    ('A'..'H').to_a.each do |letter|
      ('1'..'8').to_a.each { |number| array << letter + number }
    end
    array
  end

  def available_moves(board, game, array = [])
    all_squares.each do |square|
      examiner = MoveExaminer.new(board, self, square, game)
      array << square if examiner.validate_move 
    
    end
    array
  end

  def moves_available?(board, game)
    #available_moves(board, game).any?
    all_squares.any? do |square|
      examiner = MoveExaminer.new(board, self, square, game)
      return true if examiner.validate_move 
    
    end
    false
  end
  
end
