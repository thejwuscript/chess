# frozen_string_literal: true

require_relative '../lib/board'

RSpec.describe Board do
  subject(:board) { described_class.new }

  describe '#piece_at' do
    it 'returns the object at the coordinate given as an argument' do
      input = 'c4'
      board.grid[-4][2] = 'O'
      value = board.piece_at(input)
      expect(value).to eq('O')
    end
  end
end