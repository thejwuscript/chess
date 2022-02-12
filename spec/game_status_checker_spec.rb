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

  describe '#own_king_in_check?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    color = 'B'
    let(:enemy1) { instance_double(Bishop, position: 'H1', color: 'W') }
    let(:enemy2) { instance_double(Rook, position: 'A5', color: 'W') }
    subject(:king_checker) { described_class.new(color, board, game) }

    it 'sends a query message to board' do
      expect(board).to receive(:enemies_giving_check).with('B') { [enemy1, enemy2] }
      king_checker.own_king_in_check?
    end

    it 'returns true if the message to board returns a non-empty array' do
      allow(board).to receive(:enemies_giving_check).with('B') { [enemy1, enemy2] }
      result = king_checker.own_king_in_check?
      expect(result).to be true
    end

    it 'returns false if the message to board returns an empty array' do
      allow(board).to receive(:enemies_giving_check).with('B') { [] }
      result = king_checker.own_king_in_check?
      expect(result).to be false
    end
  end
end