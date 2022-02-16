# frozen_string_literal: true

require_relative '../lib/king'
require_relative '../lib/piece'
require_relative '../lib/rook'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/knight'
require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'

RSpec.describe King do
  include_examples 'shared #position_to_array'
  
  describe '#assign_initial_position' do
    King.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }

    it 'assigns E1 to first king' do
      first.assign_initial_position
      expect(first.position).to eql('E1')
    end

    it 'assigns E8 to second king' do
      second.assign_initial_position
      expect(second.position).to eql('E8')
    end
  end

  describe '#generate_coordinates' do
    subject(:king) { described_class.new('W', 'A6') }

    before do
      king.move_count = 1
    end

    include_examples 'shared #generate_coordinates', [[3, 1], [3, 0], [2, 1], [1, 1], [1, 0]]
  end

  describe '#possible_targets' do
    subject(:king) { described_class.new('W', 'D5') }

    before do
      king.move_count = 1
    end

    include_examples 'shared #possible_targets', ["E4", "D4", "C4", "E5", "C5", "E6", "D6", "C6"]
  end
end