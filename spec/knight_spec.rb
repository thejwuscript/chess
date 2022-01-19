# frozen_string_literal: true

require_relative '../lib/knight'
require_relative '../spec/shared_example_spec'

RSpec.describe Knight do
  include_examples 'parent class Piece methods'
  
  describe '#assign_initial_position' do
    Knight.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }
    subject(:third) { described_class.new }

    it 'assigns B1 to first knight' do
      first.assign_initial_position
      expect(first.position).to eql('B1')
    end

    it 'assigns B8 to second knight' do
      second.assign_initial_position
      expect(second.position).to eql('B8')
    end

    it 'assigns G1 to third knight' do
      third.assign_initial_position
      expect(third.position).to eql('G1')
    end
  end
end