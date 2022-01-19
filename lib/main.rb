# frozen_string_literal: true

require_relative 'game'
require_relative 'board'
require_relative 'piece'
require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

game = Game.new
game.create_all_pieces
game.assign_all_positions
game.assign_all_colors
game.assign_all_symbols
game.set_initial_positions
game.all_pieces.each {|piece| p piece}
game.board.show_board
