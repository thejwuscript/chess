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

  describe '#grid_with_spaces' do
    context 'if all elements within @grid are nil' do
      it 'outputs a nested array that has spaces in all elements ' do
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
        grid = board.grid_with_spaces
        expect(grid).to eql(nested_array)
      end
    end

    context 'if there are some elements not nil' do
      subject(:not_empty_board) { described_class.new }
      
      it 'outputs a nested array replacing only nil elements with a space' do
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
        grid = not_empty_board.grid_with_spaces
        expect(grid).to eql(nested_array)
      end
    end
  end

  describe '#set_piece' do
    it 'changes the corresponding element within @grid to the given piece' do
      position = 'b2'
      piece = 'R'
      expect { board.set_piece(position, piece) }.to change { board.grid[-2][1]}.to('R')
    end
  end
end