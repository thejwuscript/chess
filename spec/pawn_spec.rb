# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'

RSpec.describe Pawn do
  include_examples 'parent class Piece methods'

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

  describe '#en_passantable?' do
    context 'when conditions for getting captured is met' do
      pawn = Pawn.new('B', 'E7')
      pawn.position = 'E5'
      pawn.move_count = 1
      
      it 'returns true' do
      end
    end
  end
end