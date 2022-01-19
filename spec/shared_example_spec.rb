#frozen_string_literal: true

RSpec.shared_examples 'parent class Piece methods' do
  describe '#position_to_array' do
    subject { described_class.new }
  
    it "converts the piece's position to a two-element array" do
      subject.position = 'G7'
      result = subject.position_to_array
      expect(result).to eql([1, 6])
    end
  end
end