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

    context 'when a white pawn is going from A2 to A4' do
      pawn = Pawn.new('W', 'A2')
      destination = 'A4'

      it 'returns A4' do
        result = validate_board.validate_move(pawn, destination)
        expect(result).to eql('A4')
      end
    end

    context 'when a black pawn started at A7 is going from B5 to B3' do
      pawn = Pawn.new('B', 'A7')
      pawn.position = 'B5'
      destination = 'B3'

      it 'returns nil' do
        result = validate_board.validate_move(pawn, destination)
        expect(result).to be_nil
      end
    end

    context 'when a knight is moving from C4 to D2' do
      knight = Knight.new
      knight.position = 'C4'
      destination = 'D2'

      it 'returns D2' do
        result = validate_board.validate_move(knight, destination)
        expect(result).to eql('D2')
      end
    end

    context 'when a king wants to move from D4 to F2' do
      king = King.new
      king.position = 'D4'
      destination = 'F2'

      it 'returns nil' do
        result = validate_board.validate_move(king, destination)
        expect(result).to be_nil
      end
    end

    context 'when a white pawn on G5 tries en-passant a double-stepped black pawn on F5' do
      pawn = Pawn.new('W', 'G5')
      destination = 'F6'
      enemy = Pawn.new('B', 'F5')
      
      it 'returns F6' do
        validate_board.grid[3][5] = enemy
        allow(enemy).to receive(:en_passantable?).with('B').and_return true
        result = validate_board.validate_move(pawn, destination)
        expect(result).to eql('F6')
      end
    end

    context 'when a black pawn on A4 tries en-passant a double-stepped white pawn on B4' do
      pawn = Pawn.new('B', 'A4')
      destination = 'B3'
      enemy = Pawn.new('W', 'B4')
      
      it 'returns B3' do
        validate_board.grid[4][1] = enemy
        allow(enemy).to receive(:en_passantable?).with('W').and_return true
        result = validate_board.validate_move(pawn, destination)
        expect(result).to eql('B3')
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

  describe '#white_pawn_search' do
    context 'when a white pawn is moving from G2 to G3' do
      pawn = Pawn.new('W', 'G2')
      origin_ary = [6, 6]
      target_ary = [5, 6]
      
      it 'returns [5, 6]' do
        result = board.white_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to eql([5, 6])
      end
    end

    context 'when a white pawn is moving from G2 to G4' do
      pawn = Pawn.new('W', 'G2')
      origin_ary = [6, 6]
      target_ary = [4, 6]
      
      it 'returns [4, 6]' do
        result = board.white_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to eql([4, 6])
      end
    end

    context 'when a white pawn wants to move from G2 to G5' do
      pawn = Pawn.new('W', 'G2')
      origin_ary = [6, 6]
      target_ary = [3, 6]
      
      it 'returns nil' do
        result = board.white_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to be_nil
      end
    end

    context 'when a white pawn initialized on G2 wants to move from G3 to G4' do
      pawn = Pawn.new('W', 'G2')
      pawn.position = 'G3'
      origin_ary = [5, 6]
      target_ary = [3, 6]
      
      it 'returns nil' do
        result = board.white_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to be_nil
      end
    end
  end

  describe '#black_pawn_search' do
    context 'when a black pawn is moving from E7 to E6' do
      pawn = Pawn.new('B', 'E7')
      origin_ary = [1, 4]
      target_ary = [2, 4]

      it 'returns [2, 4]' do
        result = board.black_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to eql([2, 4])
      end
    end

    context 'when a black pawn is moving from E7 to E5' do
      pawn = Pawn.new('B', 'E7')
      origin_ary = [1, 4]
      target_ary = [3, 4]

      it 'returns [3, 4]' do
        result = board.black_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to eql([3, 4])
      end
    end

    context 'when a black pawn wants to move from E7 to E4' do
      pawn = Pawn.new('B', 'E7')
      origin_ary = [1, 4]
      target_ary = [4, 4]

      it 'returns nil' do
        result = board.black_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to be_nil
      end
    end

    context 'when a black pawn initialized on E7 wants to move from E6 to E4' do
      pawn = Pawn.new('B', 'E7')
      pawn.position = 'E6'
      origin_ary = [2, 4]
      target_ary = [4, 4]
      
      it 'returns nil' do
        result = board.black_pawn_search(origin_ary, pawn, target_ary)
        expect(result).to be_nil
      end
    end
  end

  describe '#pawn_attack' do
    context 'when a D4 white pawn is going to capture an E5 (black) piece' do
      color = 'W'
      origin_ary = [4, 3]
      target_ary = [3, 4]
      
      it 'returns [3, 4]' do
        board.grid[3][4] = Bishop.new('B', 'E5')
        result = board.pawn_attack(origin_ary, color, target_ary)
        expect(result).to eql([3, 4])
      end
    end

    context 'when a G3 black pawn is going to capture an F2 (white) piece' do
      color = 'B'
      origin_ary = [5, 6]
      target_ary = [6, 5]
      
      it 'returns [6, 5]' do
        board.grid[6][5] = Rook.new('W', 'F2')
        result = board.pawn_attack(origin_ary, color, target_ary)
        expect(result).to eql([6, 5])
      end
    end

    context 'when a D4 white pawn tries to move diagonally to an empty spot' do
      color = 'W'
      origin_ary = [4, 3]
      target_ary = [3, 5]
      
      it 'receives w_en_passant method' do
        expect(board).to receive(:w_en_passant).once
        board.pawn_attack(origin_ary, color, target_ary)
      end
    end

    context 'when an G3 black pawn tries to move diagonally to an empty spot' do
      color = 'B'
      origin_ary = [5, 6]
      target_ary = [6, 7]

      it 'receives b_en_passant method' do
        expect(board).to receive(:b_en_passant).once
        board.pawn_attack(origin_ary, color, target_ary)
      end
    end
  end

  describe '#w_en_passant' do
    it 'returns nil when no pawn exist for en passant' do
      row, column = [2, 3]
      board.grid[3][3] = Bishop.new
      result = board.w_en_passant(row, column)
      expect(result).to be_nil
    end

    context 'when the target pawn exist' do
      row, column = [2, 3]
      pawn = Pawn.new
      
      it 'sends a messsage to the target pawn to check for en_passant condition' do
        board.grid[3][3] = pawn
        expect(pawn).to receive(:en_passantable?).once
        board.w_en_passant(row, column)
      end

      it 'returns target array when condition is met' do
        board.grid[3][3] = pawn
        allow(pawn).to receive(:en_passantable?).and_return true
        result = board.w_en_passant(row, column)
        expect(result).to eql([2, 3])
      end
    end
  end

  describe '#b_en_passant' do
    it 'returns nil when no pawn exist for en passant' do
      row, column = [5, 3]
      board.grid[4][3] = Knight.new
      result = board.b_en_passant(row, column)
      expect(result).to be_nil
    end

    context 'when the target pawn exist' do
      row, column = [5, 3]
      pawn = Pawn.new

      it 'sends a message to the pawn to check for en_passant condition' do
        board.grid[4][3] = pawn
        expect(pawn).to receive(:en_passantable?).once
        board.b_en_passant(row, column)
      end

      it 'returns target array when condition is met' do
        board.grid[4][3] = pawn
        allow(pawn).to receive(:en_passantable?).and_return true
        result = board.b_en_passant(row, column)
        expect(result).to eql([5, 3])
      end
    end
  end

  describe '#verify_king_move' do
    subject(:king_board) { described_class.new }
    
    it 'returns true if the black king would be checked' do
      king = King.new('B', 'E6')
      target = 'F5'
      king_board.grid[3][0] = Rook.new('W', 'A5')
      result = king_board.verify_king_move(king, target)
      expect(result).to be true
    end

    it 'returns true if the white king would be checked' do
      king = King.new('W', 'D1')
      target = 'E1'
      king_board.grid[5][2] = Bishop.new('B', 'C3')
      king_board.grid[6][3] = Queen.new('W', 'D2')
      king_board.grid[6][5] = Pawn.new('B', 'F2')
      result = king_board.verify_king_move(king, target)
      expect(result).to be true
    end

    it 'returns false if the white king would be safe' do
      king = King.new('W', 'E2')
      target = 'E1'
      king_board.grid[5][2] = Bishop.new('B', 'C3')
      king_board.grid[6][3] = Queen.new('W', 'D2')
      result = king_board.verify_king_move(king, target)
      expect(result).to be false
    end
  end

  describe '#find_checked_king' do
    king = King.new('B', 'C7')
    
    it 'returns the king that is being checked' do
      board.grid[1][2] = king
      board.grid[2][1] = Pawn.new('W', 'B6')
      piece = board.find_checked_king
      expect(piece).to eql(king)
    end

    it 'returns nil when no kings are in check' do
      board.grid[1][2] = king
      board.grid[7][2] = Queen.new('W', 'C1')
      board.grid[2][2] = Queen.new('B', 'C6')
      result = board.find_checked_king
      expect(result).to be_nil
    end
  end

  describe '#checkmate?' do
    subject(:mate_board) { described_class.new }
    king = King.new('B', 'H8')
    enemy_rook = Rook.new('W', 'E8')
    
    it 'returns true when a black king is mated' do
      mate_board.grid[0][4] = enemy_rook
      mate_board.grid[2][7] = King.new('W', 'H6')
      mate_board.grid[0][7] = king
      result = mate_board.checkmate?(king)
      expect(result).to be true
    end
  end
end