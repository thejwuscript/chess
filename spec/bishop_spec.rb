# frozen_string_literal: true

require_relative '../lib/bishop'
require_relative '../spec/shared_example_spec'

RSpec.describe Bishop do
  include_examples 'parent class Piece methods'
  
  describe '#assign_initial_position' do
    Bishop.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }
    subject(:third) { described_class.new }

    it 'assigns C1 to first bishop' do
      first.assign_initial_position
      expect(first.position).to eql('C1')
    end

    it 'assigns C8 to second bishop' do
      second.assign_initial_position
      expect(second.position).to eql('C8')
    end

    it 'assigns F1 to third bishop' do
      third.assign_initial_position
      expect(third.position).to eql('F1')
    end
  end
end