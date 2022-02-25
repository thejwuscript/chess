# frozen_string_literal: true

require_relative '../../lib/pieces/piece'
require_relative '../../lib/pieces/rook'
require_relative '../../lib/pieces/bishop'
require_relative '../../lib/pieces/queen'
require_relative '../../lib/pieces/knight'
require_relative '../../lib/pieces/king'
require_relative '../../lib/pieces/pawn'
require_relative 'shared_example_spec'

RSpec.describe Rook do
  describe '#position_to_array' do
    include_examples 'shared #position_to_array'
  end

  describe '#generate_coordinates' do
    subject(:rook) { described_class.new('B', 'D3') }

    include_examples 'shared #generate_coordinates', [[6, 3], [7, 3], [4, 3], [3, 3],
      [2, 3], [1, 3], [0, 3], [5, 4], [5, 5], [5, 6], [5, 7], [5, 2], [5, 1], [5, 0]]
  end

  describe '#possible_targets' do
    subject(:rook) { described_class.new('B', 'C4') }

    include_examples 'shared #possible_targets', ["C3", "C2", "C1", "C5",
      "C6", "C7", "C8", "D4", "E4", "F4", "G4", "H4", "B4", "A4"]
  end
  
  describe '#assign_initial_position' do
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
end