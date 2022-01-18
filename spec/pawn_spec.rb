# frozen_string_literal: true

require_relative '../lib/pawn'
require_relative '../spec/shared_example_spec'

RSpec.describe Pawn do
  include_examples 'parent class Piece methods'
  
  describe '#update_position_to' do
    subject(:moved_pawn) { described_class.new }
    
    it 'updates @position to the position given as an argument' do
      moved_pawn.position = 'D1'
      new_position = 'H1'
      moved_pawn.update_position_to(new_position)
      expect(moved_pawn.position).to eql(new_position)
    end
  end
end