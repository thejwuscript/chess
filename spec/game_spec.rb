# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'

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

#subject(:place_pawn) { described_class.new('W', 'E2') }
#    let(:pawn_board) { instance_double(Board) }
#    
#    it 'sends a message to board to include self in grid #array' do
#      expect(pawn_board).to #receive(set_piece_at).with('E2', place_pawn)
#    end