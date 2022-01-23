# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'
require_relative '../lib/game'

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

  describe '#en_passant_position?' do
    context 'when a black pawn is in position' do
      subject(:risky_pawn) { described_class.new('B', 'G5') }
      
      it 'returns true' do
        expect(risky_pawn).to be_en_passant_position
      end
    end

    context 'when a white pawn is in position' do
      subject(:risk_taking_pawn) { described_class.new('W', 'A4') }

      it 'returns true' do
        expect(risk_taking_pawn).to be_en_passant_position
      end
    end
  end

  describe '#en_passantable_turn?' do
    context 'when pawn took a double-step on turn 2 and it is now turn 4' do
      subject(:safe_pawn) { described_class.new }
      Game.turn_count = 4
      
      it 'returns false' do
        safe_pawn.double_step_turn = 2
        result = safe_pawn.en_passantable_turn?
        expect(result).to be false
      end
    end

    context 'when pawn took a double-step on turn 4 and it is now turn 5' do
      subject(:danger_pawn) { described_class.new }
      Game.turn_count = 5
      
      it 'returns true' do
        danger_pawn.double_step_turn = 4
        result = danger_pawn.en_passantable_turn?
        expect(result).to be true
      end
    end
  end
end