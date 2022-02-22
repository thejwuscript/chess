# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'
require_relative '../lib/game'
require_relative '../lib/king'
require_relative '../lib/piece'
require_relative '../lib/rook'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/knight'

RSpec.describe Pawn do
  describe '#position_to_array' do
    include_examples 'shared #position_to_array'
  end

  describe '#assign_initial_position' do
    Pawn.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }
    subject(:third) { described_class.new }
    
    it 'assigns A2 to first pawn' do
      first.assign_initial_position
      expect(first.position).to eql('A2')
    end

    it 'assigns A7 to second pawn' do
      second.assign_initial_position
      expect(second.position).to eql('A7')
    end

    it 'assigns B2 to third pawn' do
      third.assign_initial_position
      expect(third.position).to eql('B2')
    end
  end

  describe '#generate_coordinates' do
    context 'when it is a black pawn' do
      subject(:pawn) { described_class.new('B', 'E6') }
    
      include_examples 'shared #generate_coordinates', 
                       [[3, 4], [4, 4], [3, 5], [3, 3]]
      include_examples 'shared #possible_targets', ["E5", "E4", "F5", "D5"]
    end

    context 'when it is a white pawn' do
      subject(:pawn) { described_class.new('W', 'E6') }
      
      include_examples 'shared #generate_coordinates',
                       [[1, 4], [0, 4], [1, 5], [1, 3]]
      include_examples 'shared #possible_targets', ["E7", "E8", "F7", "D7"]
    end
  end
end