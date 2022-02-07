# frozen_string_literal: true

require_relative '../lib/move_examiner'
require_relative '../lib/board'

RSpec.describe MoveExaminer do
  subject(:examiner) { described_class.new }
  let(:board) { instance_double(Board) }
  let(:piece) { double('piece') }

  before do
    examiner.board = board
  end

  describe '#position_to_array' do
    it 'converts A1(lower-left corner) to [7, 0]' do
      result = examiner.position_to_array('A1')
      expect(result).to eq([7, 0])
    end

    it 'converts A8(upper-left corner) to [0, 0]' do
      result = examiner.position_to_array('A8')
      expect(result).to eq([0, 0])
    end

    it 'converts H8(upper-right corner) to [0, 7]' do
      result = examiner.position_to_array('H8')
      expect(result).to eq([0, 7])
    end

    it 'converts H1(lower-right corner) to [7, 7]' do
      result = examiner.position_to_array('H1')
      expect(result).to eq([7, 7])
    end
  end

  describe '#within_limits?' do
    context 'when elements greater than 7 is out of bounds' do
      array = [8, 0]
      it { is_expected.not_to be_within_limits(array) }
    end

    context 'when elements 7 or less is within limits' do
      array = [7, 7]
      it { is_expected.to be_within_limits(array) }
    end
  end

  describe '#depth_search' do
    context 'when the path from [0, 0] to [5, 0] is clear' do
      it 'returns [5, 0]' do
        start = [0, 0]
        target_ary = [5, 0]
        manner = [1, 0]
        allow(board).to receive(:occupied?).and_return(false).exactly(4).times
        result = examiner.depth_search(start, manner, target_ary)
        expect(result).to eql([5, 0])
      end
    end

    context 'when a piece is blocking the path from [0, 0] to [5, 0]' do
      it 'returns nil' do
        start = [0, 0]
        target_ary = [5, 0]
        manner = [1, 0]
        allow(board).to receive(:occupied?).and_return(false, false, true)
        result = examiner.depth_search(start, manner, target_ary)
        expect(result).to be_nil
      end
    end
  end

  describe '#breadth_search' do
    context 'when a piece is making a move from [6, 6] to [5, 4] unhindered' do
      start = [6, 6]
      target_ary = [5, 4]
      
      it 'returns [5, 4]' do
        manners = [[1, 2], [2, 1], [-1, -2]]
        result = examiner.breadth_search(start, manners, target_ary)
        expect(result).to eql([5, 4])
      end

      it 'loops through manners array until the target array is found' do
        manners = [[1, 2], [2, 1], [-1, -2]]
        expect(examiner).to receive(:within_limits?).exactly(3).times
        examiner.breadth_search(start, manners, target_ary)
      end
    end
  end

  describe '#pawn_move_search' do
    context 'when a white pawn is moving from [6, 1] to [4, 1]' do
      target_ary = [4, 1]
      
      before do
        allow(piece).to receive(:position).and_return('B2')
        allow(piece).to receive(:color).and_return('W')
        allow(piece).to receive(:possible_moves).and_return([[5, 1], [4, 1]])
      end
    
      it 'returns [4, 1] when unobstructed' do
        allow(board).to receive(:occupied?).and_return(false, false)
        result = examiner.pawn_move_search(piece, target_ary)
        expect(result).to eq([4, 1])
      end

      it 'returns nil when obstructed' do
        allow(board).to receive(:occupied?).and_return(false, true)
        result = examiner.pawn_move_search(piece, target_ary)
        expect(result).to be_nil
      end
    end
  end
end
