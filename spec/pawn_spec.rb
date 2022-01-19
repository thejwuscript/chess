# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'

RSpec.describe Pawn do
  describe '#initialize' do
    subject(:first_pawn) { described_class.new }
    subject(:second_pawn) { described_class.new }
    subject(:third_pawn) { described_class.new('Q') }
    
    it 'assigns white and position A2 to the first pawn' do
      color = first_pawn.color
      position = first_pawn.position
      expect(color).to eql('W')
      expect(position).to eql('A2')
    end

    it 'assigns black and position A7 to the second pawn' do
      color = second_pawn.color
      position = second_pawn.position
      expect(color).to eql('B')
      expect(position).to eql('A7')
    end

    context 'when third pawn takes a string as an argument' do
      it 'assigns position B2 and the string to @color respectively' do
        string = third_pawn.color
        position = third_pawn.position
        expect(string).to eql('Q')
        expect(position).to eql('B2')
      end
    end
  end

  describe '#update_position_to' do
    subject(:moved_pawn) { described_class.new }
    
    it 'updates @position to the position given as an argument' do
      new_position = 'H1'
      moved_pawn.update_position_to(new_position)
      expect(moved_pawn.position).to eql(new_position)
    end
  end

  include_examples 'parent class Piece methods'
end