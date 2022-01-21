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

  describe '#validate_move' do
    subject(:validate_board) { described_class.new }
    
    context 'when a rook on A8 is moving to A5 unhindered' do
      rook = Rook.new('W', 'A8')
      destination = 'A5'
      
      it 'returns A5' do
        result = validate_board.validate_move(rook, destination)
        expect(result).to eql('A5')
      end
    end

    context 'when a rook on A8 wants to move to A3 with a piece on A4' do
      blocked_rook = Rook.new('W', 'A8')
      destination = 'A3'
      
      it 'returns nil' do
        validate_board.grid[4][0] = Pawn.new
        result = validate_board.validate_move(blocked_rook, destination)
        expect(result).to be_nil
      end
    end

    context 'when a bishop on C1 is moving to H6 unhindered' do
      bishop = Bishop.new('B', 'C1')
      destination = 'H6'

      it 'returns H6' do
        result = validate_board.validate_move(bishop, destination)
        expect(result).to eql('H6')
      end
    end

    context 'when a bishop from F7 is blocked from going to B3' do
      bishop = Bishop.new('W', 'F7')
      destination = 'B3'
      
      it 'returns nil' do
        validate_board.grid[2][4] = Rook.new
        result = validate_board.validate_move(bishop, destination)
        expect(result).to be_nil
      end
    end

    context 'when a queen from D8 is moving to A5 unhindered' do
      queen = Queen.new('W', 'D8')
      destination = 'A5'

      it 'returns A5' do
        result = validate_board.validate_move(queen, destination)
        expect(result).to eql('A5')
      end
    end

    context 'when a queen from C6 is blocked from going to H1' do
      queen = Queen.new('W', 'C6')
      destination = 'H1'

      it 'returns nil' do
        validate_board.grid[6][6] = Knight.new
        result = validate_board.validate_move(queen, destination)
        expect(result).to be_nil
      end
    end
  
  end

  describe '#within_limits?' do
    context 'when elements greater than 7 is out of bounds' do
      array = [8, 0]
      it { is_expected.not_to be_within_limits(array) }
    end

    context 'when elements 7 or less is within limits' do
      array = [7, 7]
      it { is_expected.to be_within_limits(array) }
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

  describe '#recursive_search' do
    context 'when a rook is moving from A8 to F8 unhindered' do
      origin_ary = [0, 0]
      target_ary = [0, 5]
      manner = [0, 1]

      it 'returns [0, 5]' do
        result = board.recursive_search(origin_ary, manner, target_ary)
        expect(result).to eql([0, 5])
      end
    end

    context 'when a rook is trying to move from B2 to B6 with a piece in between' do
      origin_ary = [6, 1]
      target_ary = [2, 1]
      manner = [-1, 0]

      it 'returns nil' do
        board.grid[3][1] = Queen.new
        result = board.recursive_search(origin_ary, manner, target_ary)
        expect(result).to be_nil
      end
    end
  end

  describe '#breadth_search' do
    
    context 'when a knight is making a move from G2 to E3 unhindered' do
      origin_ary = [6, 6]
      target_ary = [5, 4]
      manners = Knight.new.move_manner
      
      it 'returns [5, 4]' do
        result = board.breadth_search(origin_ary, manners, target_ary)
        expect(result).to eql([5, 4])
      end
    end

    context 'when a knight cannot make a legal move' do
      origin_ary = [5, 5]
      target_ary = [1, 1]
      manners = Knight.new.move_manner

      it 'returns nil' do
        result = board.breadth_search(origin_ary, manners, target_ary)
        expect(result).to be_nil
      end
    end

    context 'when a king is moving from D4 to E5 unhindered' do
      origin_ary = [4, 3]
      target_ary = [3, 4]
      manners = King.new.move_manner

      it 'returns [3, 4]' do
        result = board.breadth_search(origin_ary, manners, target_ary)
        expect(result).to eql([3, 4])
      end
    end

    context 'when a king makes a move out of his capacity' do
      origin_ary = [3, 7]
      target_ary = [2, 2]
      manners = King.new.move_manner

      it 'returns nil' do
        result = board.breadth_search(origin_ary, manners, target_ary)
        expect(result).to be_nil
      end
    end
  end

  
end