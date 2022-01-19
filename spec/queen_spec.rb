# frozen_string_literal: true

require_relative '../lib/queen'
require_relative '../spec/shared_example_spec'

RSpec.describe Queen do
  include_examples 'parent class Piece methods'
  
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