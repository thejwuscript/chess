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
    let(:rook) { instance_double(Rook, is_a?: Rook) }
    let(:enemy) { instance_double(Bishop) }
    subject(:condition_checker) { described_class.new(board, king, [7, 2]) }
    
    context 'when meet_prerequisites? returns true twice then false' do
      it 'returns false' do
        allow(condition_checker).to receive(:meet_prerequisites?).and_return(true, true, false)
        allow(condition_checker).to receive(:next_piece)
        result = condition_checker.meet_castling_condition?
        expect(result).to be false
      end
    end

    context 'when the path between the rook and the king is not empty' do
      it 'returns false' do
        allow(condition_checker).to receive(:meet_prerequisites?).and_return(true, true, true)
        allow(condition_checker).to receive(:next_piece).and_return(nil, enemy)
        result = condition_checker.meet_castling_condition?
        expect(result).to be false
      end
    end

    context 'when the rook has been moved once' do
      it 'returns false' do
        allow(condition_checker).to receive(:meet_prerequisites?).and_return(true, true, true, true)
        allow(condition_checker).to receive(:next_piece).and_return(nil, nil, nil, rook)
        allow(rook).to receive(:move_count).and_return(1)
        result = condition_checker.meet_castling_condition?
        expect(result).to be false
      end
    end

    context 'when the rook has not moved, path is empty, pre-reqs are met' do
      it 'returns true' do
        allow(condition_checker).to receive(:meet_prerequisites?).and_return(true, true, true, true)
        allow(condition_checker).to receive(:next_piece).and_return(nil, nil, nil, rook)
        allow(rook).to receive(:move_count).and_return(0)
        result = condition_checker.meet_castling_condition?
        expect(result).to be true
      end
    end
  end

  describe '#modifier' do
    let(:board) { instance_double(Board) }
    let(:king) { instance_double(King, position: 'E8', color: 'B') }
    
    context 'when performing long castling' do
      subject(:mod_checker) { described_class.new(board, king, [0, 2]) }
      
      it 'returns -1' do
        result = mod_checker.send(:modifier)
        expect(result).to eq(-1)
      end
    end

    context 'when performing short castling' do
      subject(:mod_checker) { described_class.new(board, king, [0, 6]) }
      
      it 'returns 1' do
        result = mod_checker.send(:modifier)
        expect(result).to eq(1)
      end
    end
  end

  describe '#next_piece' do
    let(:board) { instance_double(Board) }
    let(:king) { instance_double(King, position: 'E8', color: 'B') }
    let(:rook) { instance_double(Rook) }

    context 'when performing LONG castling' do
      subject(:left_checker) { described_class.new(board, king, [0, 2]) }
    
      it 'returns the chess piece to the adjacent LEFT, when present' do
        allow(board).to receive(:grid) {[
          [nil, nil, nil, rook, king, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]}
        result = left_checker.send(:next_piece, 0, 4)
        expect(result).to eq(rook)
      end

      it 'returns nil if there are no chess piece to the adjacent LEFT' do
        allow(board).to receive(:grid) {[
          [nil, nil, nil, nil, king, rook, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]}
        result = left_checker.send(:next_piece, 0, 4)
        expect(result).to be_nil
      end
    end

    context 'when performing SHORT castling' do
      subject(:right_checker) { described_class.new(board, king, [0, 6]) }

      it 'returns the chess piece to the adjacent RIGHT, when present' do
        allow(board).to receive(:grid) {[
          [nil, nil, nil, nil, king, rook, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]}
        result = right_checker.send(:next_piece, 0, 4)
        expect(result).to eq(rook)
      end

      it 'returns nil when there is no chess piece to the adjacent RIGHT' do
        allow(board).to receive(:grid) {[
          [nil, nil, nil, rook, king, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]}
        result = right_checker.send(:next_piece, 0, 4)
        expect(result).to be_nil
      end
    end
  end

  describe '#meet_prerequisites?' do
    let(:board) { instance_double(Board) }
    let(:king) { instance_double(King, position: 'E1', color: 'W') }
    let(:enemy) { instance_double(Bishop) }
    let(:game_status_checker) { instance_double(GameStatusChecker) }
    subject(:prereq_checker) { described_class.new(board, king, [7, 6]) }

    context 'when the king would not be in check at the given position' do
      it 'returns true' do
        allow(board).to receive(:move_piece_to_target)
        allow(GameStatusChecker).to receive(:new).with('W', board) { game_status_checker }
        allow(game_status_checker).to receive(:own_king_in_check?).and_return false
        result = prereq_checker.send(:meet_prerequisites?, [7, 4], 0)
        expect(result).to be true
      end
    end

    context 'when the king would be in check at the given position' do
      it 'returns false' do
        allow(board).to receive(:move_piece_to_target)
        allow(GameStatusChecker).to receive(:new).with('W', board) { game_status_checker }
        allow(game_status_checker).to receive(:own_king_in_check?).and_return true
        result = prereq_checker.send(:meet_prerequisites?, [7, 4], 0)
        expect(result).to be false
      end
    end

    context 'when the given array is out of bounds' do
      it 'returns false' do
        result = prereq_checker.send(:meet_prerequisites?, [7, 8], 4)
        expect(result).to be false
      end
    end
  end
end
