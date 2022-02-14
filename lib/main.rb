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
require_relative 'player'
require_relative 'board_display'
require_relative 'castling_checker'
require_relative 'converter'
require_relative 'en_passant_checker'
require_relative 'game_status_checker'
require_relative 'move_examiner'
require_relative 'computer_player'
require_relative 'human_player'


Game.new.play