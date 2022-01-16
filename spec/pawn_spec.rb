# frozen_string_literal: true

require_relative '../lib/pawn'

RSpec.describe Pawn do
  describe '#update_position_to' do
    subject(:moved_pawn) { described_class.new('B', 'D1') }
    
    it 'updates @position to the position given as an argument' do
      new_position = 'H1'
      moved_pawn.update_position_to(new_position)
      expect(moved_pawn.position).to eql(new_position)
    end
  end

  describe '#initialize' do
    context 'when color of the piece is white' do
      subject(:white_pawn) { described_class.new('W', 'D1') }
      
      it 'assigns ♙ to @symbol' do
        expect(white_pawn.symbol).to eql('♙')
      end
    end

    context 'when color of the piece is black' do
      subject(:black_pawn) { described_class.new('B', 'F2') }

      it 'assigns ♟︎ to @symbol' do
        expect(black_pawn.symbol).to eql('♟︎')
      end
    end
  end

  describe '#position_to_array' do
    subject(:pawn_array) { described_class.new('B', 'G7') }
    
    it "converts the piece's position to a two-element array" do
      result = pawn_array.position_to_array
      expect(result).to eql([1, 6])
    end
  end
    
end
