# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'
require_relative '../lib/pawn'

RSpec.describe Game do
  subject(:game) { described_class.new }
  
  describe '#place_on_board' do
    context 'when a piece is initialized' do
      let(:piece) { double('piece', position: 'E2') }
      
      it 'sends a message to board to include the piece in @grid' do
        board = game.board
        position = piece.position
        expect(board).to receive(:set_piece_at).with(position, piece)
        game.place_on_board(piece)
      end
    end
  end

end

