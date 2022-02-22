# frozen_string_literal: true

require_relative '../../lib/pieces/queen'
require_relative '../shared_example_spec'

RSpec.describe Queen do
  describe '#position_to_array' do
    include_examples 'shared #position_to_array'
  end 
  
  describe '#assign_initial_position' do
    Queen.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }

    it 'assigns D1 to first queen' do
      first.assign_initial_position
      expect(first.position).to eql('D1')
    end

    it 'assigns D8 to second queen' do
      second.assign_initial_position
      expect(second.position).to eql('D8')
    end
  end
end