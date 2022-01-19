# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../spec/shared_example_spec'

RSpec.describe Rook do
  include_examples 'parent class Piece methods'
  
  describe '#assign_initial_position' do
    Rook.assignment_count = 0
    subject(:first) { described_class.new }
    subject(:second) { described_class.new }
    subject(:third) { described_class.new }

    it 'assigns A1 to first rook' do
      first.assign_initial_position
      expect(first.position).to eql('A1')
    end

    it 'assigns A8 to second rook' do
      second.assign_initial_position
      expect(second.position).to eql('A8')
    end

    it 'assigns H1 to third rook' do
      third.assign_initial_position
      expect(third.position).to eql('H1')
    end
  end
end