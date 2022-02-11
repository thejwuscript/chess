# frozen_string_literal: true

require_relative '../lib/game_status_checker'
require_relative '../lib/board'
require_relative '../lib/game'
require_relative '../lib/bishop'
require_relative '../lib/rook'
require_relative '../lib/king'

RSpec.describe GameStatusChecker do
  describe 'no_legal_moves?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:bishop1) { instance_double(Bishop) }
    let(:rook1) { instance_double(Rook) }
    let(:king) { instance_double(King) }
    color = 'W'
    subject(:no_more_moves) { described_class.new(color, board, game) }
    
    it 'sends a message #moves_available? to each ally piece on the board' do
      allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
      expect(bishop1).to receive(:moves_available?).with(board, game)
      expect(rook1).to receive(:moves_available?).with(board, game)
      expect(king).to receive(:moves_available?).with(board, game)
      no_more_moves.no_legal_moves?
    end
  
    context 'when a player cannot make any legal moves' do
      it 'returns true' do
        allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
        allow(bishop1).to receive(:moves_available?).with(board, game) { false }
        allow(rook1).to receive(:moves_available?).with(board, game) { false }
        allow(king).to receive(:moves_available?).with(board, game) { false }
        result = no_more_moves.no_legal_moves?
        expect(result).to be true
      end
    end

    context 'when a player can still make a legal move' do
      it 'returns false' do
        allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
        allow(bishop1).to receive(:moves_available?).with(board, game) { false }
        allow(rook1).to receive(:moves_available?).with(board, game) { true }
        allow(king).to receive(:moves_available?).with(board, game) { false }
        result = no_more_moves.no_legal_moves?
        expect(result).to be false
      end
    end
  end
end