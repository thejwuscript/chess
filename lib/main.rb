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
game.assign_all_attributes
game.set_initial_positions
game.board.show_board
game.move_piece
game.board.show_board
