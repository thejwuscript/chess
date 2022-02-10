# frozen_string_literal: true

require_relative '../lib/castling_checker'
require_relative '../lib/board'
require_relative '../lib/king'
require_relative '../lib/rook'
require_relative '../lib/bishop'

RSpec.describe CastlingChecker do
  describe '#meet_castling_condition?' do
    context 'when trying for long castling' do
      let(:board) { instance_double(Board) }
      let(:king) { instance_double(King, position: 'E1', color: 'W') }
      let(:rook) { instance_double(Rook, is_a?: Rook, move_count: 0) }
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
  
      it 'returns false if a piece is still in the path' do
        allow(board).to receive(:checked?).with(king, 'E1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'D1').and_return(false)
        allow(board).to receive(:grid) {[
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [rook, nil, bishop, nil, king, nil, nil, nil]
        ]}
        result = checker.meet_castling_condition?
        expect(result).to be false
      end
  
      it 'returns false if the piece is next to the rook, blocking the path' do
        allow(board).to receive(:checked?).with(king, 'E1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'D1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'C1').and_return(false)
        allow(board).to receive(:grid) {[
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [rook, bishop, nil, nil, king, nil, nil, nil]
        ]}
        result = checker.meet_castling_condition?
        expect(result).to be false
      end
  
      it 'returns false if there is no rook to do castling with' do
        allow(board).to receive(:checked?).with(king, 'E1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'D1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'C1').and_return(false)
        allow(board).to receive(:grid) {[
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, king, nil, nil, nil]
        ]}
        result = checker.meet_castling_condition?
        expect(result).to be false
      end
  
      context 'when the castling conditions are met' do
        it 'returns true' do
        allow(board).to receive(:checked?).with(king, 'E1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'D1').and_return(false)
        allow(board).to receive(:checked?).with(king, 'C1').and_return(false)
          allow(board).to receive(:grid) {[
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [rook, nil, nil, nil, king, nil, nil, nil]
          ]}
          result = checker.meet_castling_condition?
          expect(result).to be true
        end
  
        it 'sends query message checked? to board three times with different positions as arguments' do
          allow(board).to receive(:grid) {[
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [rook, nil, nil, nil, king, nil, nil, nil]
          ]}
          expect(board).to receive(:checked?).with(king, 'E1')
          expect(board).to receive(:checked?).with(king, 'D1')
          expect(board).to receive(:checked?).with(king, 'C1')
          checker.meet_castling_condition?
        end
      end
    end
  end
end