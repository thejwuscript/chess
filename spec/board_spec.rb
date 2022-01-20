# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'
require_relative '../lib/pawn'

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

  describe '#validate_rook_move' do
    subject(:rook_board) { described_class.new }
    
    context 'when a rook on A8 is moving to A5 unhindered' do
      rook = Rook.new('W', 'A8')
      destination = 'A5'
      
      it 'returns the input' do
        result = rook_board.validate_rook_move(rook, destination)
        expect(result).to eql('A5')
      end
    end

    context 'when a rook on A8 wants to move to A3 with a piece on A4' do
      blocked_rook = Rook.new('W', 'A8')
      destination = 'A3'
      
      it 'returns nil' do
        rook_board.grid[4][0] = Pawn.new
        result = rook_board.validate_rook_move(blocked_rook, destination)
        expect(result).to be_nil
      end
    end
  end

end