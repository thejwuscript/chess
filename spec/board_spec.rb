# frozen_string_literal: true

require_relative '../lib/board'

RSpec.describe Board do
  subject(:board) { described_class.new }

  describe '#piece_at' do
    it 'returns the object at the coordinate given as an argument' do
      input = 'c4'
      board.grid[-4][2] = 'O'
      value = board.piece_at(input)
      expect(value).to eql('O')
    end
  end

  describe '#insert_spaces' do # to prepare for show_board
    context 'if all elements within @grid are nil' do
      it 'replaces all elements with a space' do
        nested_array = [
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
        ]
        board.insert_spaces
        grid = board.grid
        expect(grid).to eql(nested_array)
      end
    end

    context 'if there are some elements not nil' do
      subject(:not_empty_board) { described_class.new }
      
      it 'replaces only nil elements with a space' do
        not_empty_board.grid[-3][3] = 'P'
        not_empty_board.grid[-2][3] = 'K'
        nested_array = [
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', 'P', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', 'K', ' ', ' ', ' ', ' '],
          [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
        ] 
        not_empty_board.insert_spaces
        grid = not_empty_board.grid
        expect(grid).to eql(nested_array)
      end
    end
  end
      
end