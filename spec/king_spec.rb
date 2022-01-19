# frozen_string_literal: true

require_relative '../lib/king'
require_relative '../spec/shared_example_spec'

RSpec.describe King do
  include_examples 'parent class Piece methods'
  
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
end