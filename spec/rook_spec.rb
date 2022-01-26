# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../spec/shared_example_spec'

RSpec.describe Rook do
  include_examples 'parent class Piece methods'
  
  describe '#assign_initial_position' do
    Rook.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }
    subject(:third) { described_class.new }

    it 'assigns A1 to first rook' do
      first.assign_initial_position
      expect(first.position).to eql('A1')
    end

    it 'assigns A8 to second rook' do
      second.assign_initial_position
      expect(second.position).to eql('A8')
    end

    it 'assigns H1 to third rook' do
      third.assign_initial_position
      expect(third.position).to eql('H1')
    end
  end

  describe '#move_by' do
    subject(:move_rook) { described_class.new }
    
    it 'returns a two-element array by combining values of two arrays' do
      move_rook.position = 'A1'
      move_array = [-1, 0]
      result = move_rook.move_by(move_array)
      expect(result).to eql([6, 0])
    end
  end

  describe '#within_limits?' do
    subject(:limit_rook) { described_class.new }

    context 'when elements greater than 7 is out of bounds' do
      it 'returns false if the array provided is out of bounds' do
        array = [8, 0]
        expect(limit_rook).not_to be_within_limits(array)
      end

      it 'returns true if the array provided is within limits' do
        array = [7, 7]
        expect(limit_rook).to be_within_limits(array)
      end
    end
  end
end