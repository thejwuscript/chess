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
require_relative 'game_message'
require_relative 'board_display'
require_relative 'castling_checker'
require_relative 'converter'
require_relative 'en_passant_checker'
require_relative 'game_status_checker'
require_relative 'move_examiner'
require_relative 'computer_player'
require_relative 'human_player'

include SaveAndLoad

def load_or_new_game
  return Game.new.play(1) unless saved_game_exists?

  load_game? ? load_from_yaml.play(2) : Game.new.play(1)
rescue SystemCallError
  no_saved_game_message
  Game.new.play(1)
end

puts "Welcome to CHESS."
load_or_new_game