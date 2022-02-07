# frozen_string_literal: true

require_relative '../lib/move_examiner'

RSpec.describe MoveExaminer do
  subject(:examiner) { described_class.new }
  
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
    context 'when a rook is moving from A8 to F8 unhindered' do
      it 'returns [0, 5]' do
        result = board.depth_search
        expect(result).to eql([0, 5])
      end
    end

    context 'when a rook is trying to move from B2 to B6 with a piece in between' do
      it 'returns nil' do
        result = board.depth_search
        expect(result).to be_nil
      end
    end
  end
end
