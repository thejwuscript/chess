# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/pieces/rook'
require_relative '../lib/pieces/knight'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/pawn'

RSpec.describe Board do
  subject(:board) { described_class.new }

  describe '#piece_at' do
    it 'returns the object at the coordinate given as an argument' do
      input = 'C5'
      board.grid[3][2] = 'O'
      value = board.piece_at(input)
      expect(value).to eql('O')
    end
  end

  describe '#set_piece_at' do
    it 'changes the corresponding element within @grid to the given piece' do
      position = 'B2'
      piece = 'R'
      expect { board.set_piece_at(position, piece) }.to change { board.grid[6][1]}.to('R')
    end
  end

  describe '#occupied?' do
    context 'when the @grid element is occupied by a piece' do
      let(:piece) { double('piece') }
      
      it 'returns true' do
        board.grid[4][4] = piece
        array = [4, 4]
        expect(board).to be_occupied(array)
      end
    end

    context 'when the @grid element is nil' do
      it 'returns false' do
        board.grid[5][5] = nil
        array = [5, 5]
        expect(board).not_to be_occupied(array)
      end
    end
  end

  describe '#same_color_at?' do
    context 'when the origin piece and the piece on said position have the same color' do
      let(:black_piece) { double(color: 'B') }
      position = 'G2'
      
      it 'returns true' do
        board.grid[6][6] = Bishop.new('B')
        result = board.same_color_at?(position, black_piece)
        expect(result).to be true
      end
    end

    context 'when there is no piece on the said position' do
      let(:white_piece) { double(color: 'W') }
      position = 'G8'
      
      it 'returns nil' do
        result = board.same_color_at?(position, white_piece)
        expect(result).to be_nil
      end
    end

    context 'when the color of piece on said position is different' do
      let(:black_piece) { double(color: 'B') }
      position = 'C4'
      
      it 'returns false' do
        board.grid[4][2] = Knight.new('W')
        result = board.same_color_at?(position, black_piece)
        expect(result).to be false
      end
    end
  end

  describe '#all_enemies' do
    it 'returns an array of enemies on the board' do
      my_color = 'W'
      rook = Rook.new('B')
      board.grid[2][3] = rook
      result = board.all_enemies(my_color)
      expect(result.size).to eq(1)
    end
  end
end