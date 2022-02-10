# frozen_string_literal: true

require_relative '../lib/castling_checker'
require_relative '../lib/board'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/bishop'

RSpec.describe CastlingChecker do
  describe '#meet_castling_condition?' do
    let(:board) { instance_double(Board) }
    let(:king) { instance_double(King, position: 'E1', color: 'W') }
    let(:rook) { instance_double(Rook, move_count: 0) }
    let(:bishop) { instance_double(Bishop)}
    subject(:checker) { described_class.new(board, king, [7, 2]) }
    
    it 'sends a query message #checked? to @board' do
      allow(board).to receive(:grid) {[
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [rook, nil, nil, bishop, king, nil, nil, nil]
      ]}
      expect(board).to receive(:checked?).with(king, king.position)
      checker.meet_castling_condition?
    end

    it 'returns false if the king is in check' do
      allow(board).to receive(:checked?).with(king, king.position).and_return(true)
      allow(board).to receive(:grid)
      result = checker.meet_castling_condition?
      expect(result).to be false
    end

    it 'returns false if the next square to check is occupied by a piece other than a rook' do
      allow(board).to receive(:checked?).with(king, king.position).and_return(false)
      allow(board).to receive(:grid) {[
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [rook, nil, nil, bishop, king, nil, nil, nil]
      ]}
      result = checker.meet_castling_condition?
      expect(result).to be false
    end
  end
end