# frozen_string_literal: true

require_relative 'game'
require_relative 'board'
require_relative 'pieces/piece'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'game_message'
require_relative 'board_display'
require_relative 'move_examiners/castling_checker'
require_relative 'converter'
require_relative 'move_examiners/en_passant_checker'
require_relative 'game_status_checker'
require_relative 'move_examiners/move_examiner'
require_relative 'players/computer_player'
require_relative 'players/human_player'

include SaveAndLoad

def load_or_new_game
  return Game.new.play(1) unless saved_game_exists?

  load_game? ? load_from_yaml.play(2) : Game.new.play(1)
rescue SystemCallError
  no_saved_game_message
  Game.new.play(1)
end

system('clear')

puts <<-heredoc
\e[38;5;87m
 ██████╗██╗  ██╗███████╗███████╗███████╗
██╔════╝██║  ██║██╔════╝██╔════╝██╔════╝
██║     ███████║█████╗  ███████╗███████╗
██║     ██╔══██║██╔══╝  ╚════██║╚════██║
╚██████╗██║  ██║███████╗███████║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
\e[0m                                   
heredoc
load_or_new_game