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

  describe '#deep_clone' do
    knight = Knight.new('W', 'E4')
    grid = [
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, knight, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]
    ]

    before do
      board.instance_variable_set(:@grid, grid)
    end

    it 'makes a clone that responds to #grid' do
      clone = board.deep_clone
      expect(clone).to respond_to(:grid)
    end
  
    it 'makes a clone of the grid structure' do
      clone = board.deep_clone
      expect(clone.grid).to be_a_kind_of(Array)
                        .and include(a_kind_of(Array)).exactly(8).times
    end
  
    it 'makes clones of the pieces on the board in terms of type and attributes' do
      clone = board.deep_clone
      cloned_piece = clone.grid[4][4]
      original_piece = board.grid[4][4]
      expect(cloned_piece).to be_kind_of(Knight).and have_attributes(color: 'W', position: 'E4')
    end

    it 'the pieces cloned are different instances than their counterpart' do
      clone = board.deep_clone
      cloned_piece = clone.grid[4][4]
      original_piece = board.grid[4][4]
      expect(cloned_piece).not_to eq(original_piece)
    end
  end

  describe '#find_own_king_in_check' do
    king = King.new('W', 'H2')
    enemy = Rook.new('B', 'A2')
    ally = Queen.new('W', 'C2')

    context 'when the king is in check' do
      grid = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [enemy, nil, nil, nil, nil, nil, nil, king],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      it 'returns the king' do
        board.instance_variable_set(:@grid, grid)
        result = board.find_own_king_in_check('W')
        expect(result).to eq(king)
      end
    end

    context 'when the king is not in check' do
      grid = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [enemy, nil, ally, nil, nil, nil, nil, king],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      it 'returns nil' do
        board.instance_variable_set(:@grid, grid)
        result = board.find_own_king_in_check('W')
        expect(result).to be_nil
      end
    end
  end

  describe '#promotion_candidate' do
    let(:pawn) { instance_double(Pawn, is_a?: Pawn) }
    
    context 'when a pawn is at the top edge of the board' do
      it 'returns the pawn' do
        grid = [
          [nil, nil, nil, nil, nil, pawn, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        result = board.promotion_candidate
        expect(result).to eq(pawn)
      end
    end

    context 'when a pawn is at the bottom edge of the board' do  
      it 'returns the pawn' do
        grid = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, pawn, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        result = board.promotion_candidate
        expect(result).to eq(pawn)
      end
    end

    context 'when a pawn is not at the top or bottom edge of the board' do
      it 'returns nil' do
        grid = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, pawn, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        result = board.promotion_candidate
        expect(result).to be_nil
      end
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

  describe '#enemies_giving_check' do
    it 'returns an array of enemy pieces giving check' do
      bking = King.new('B', 'E4')
      wknight = Knight.new('W', 'C5')
      wrook = Rook.new('W', 'A4')
      wking = King.new('W', 'A2')
      grid = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, wknight, nil, nil, nil, nil, nil],
        [wrook, nil, nil, nil, bking, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [wking, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      board.instance_variable_set(:@grid, grid)
      result = board.enemies_giving_check('B', 'E4')
      expect(result).to eq([wknight, wrook])
    end

    it 'returns an empty array if no enemies are giving check' do
      bking = King.new('B', 'E4')
      wknight = Knight.new('W', 'A4')
      wrook = Rook.new('W', 'A5')
      wking = King.new('W', 'A2')
      grid = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [wrook, nil, nil, nil, nil, nil, nil, nil],
        [wknight, nil, nil, nil, bking, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [wking, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      board.instance_variable_set(:@grid, grid)
      result = board.enemies_giving_check('B', nil)
      expect(result).to eq([])
    end
  end

  describe '#remove_pawn_captured_en_passant' do
    context 'when white is capturing black pawn' do
      bpawn = Pawn.new('B', 'D5')
      wpawn = Pawn.new('W', 'E5')
    
      it 'changes the element of where the captured pawn is at to nil' do
        grid = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, bpawn, wpawn, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        board.remove_pawn_captured_en_passant(wpawn, 'D6')
        expected = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, wpawn, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        expect(board.grid).to eq(expected)
      end
    end

    context 'when black is capturing white pawn' do
      bpawn = Pawn.new('B', 'B4')
      wpawn = Pawn.new('W', 'C4')
      
      it 'changes the element of where the captured pawn is at to nil' do
        grid = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, bpawn, wpawn, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        board.remove_pawn_captured_en_passant(bpawn, 'C3')
        expected = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, bpawn, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        expect(board.grid).to eq(expected)
      end
    end
  end

  describe '#move_piece_to_target' do
    let(:bishop) { instance_double(Bishop, position: 'F1') }
    
    it 'moves a piece to the specified position given as an argument' do
      grid = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, bishop, nil, nil]
      ]
      board.instance_variable_set(:@grid, grid)
      board.move_piece_to_target('A6', bishop)
      expected = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [bishop, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      expect(board.grid).to eq(expected)
    end
  end

  describe '#move_castle' do
    context 'when a king is moving to C8 due to castling' do
      let(:rook) { instance_double(Rook, color: 'B', position: 'A8') }

      before do
        grid = [
          [rook, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
      end
    
      it 'moves the rook from A8 to D8' do
        allow(rook).to receive(:update_position)
        board.move_castle('C8')
        expected = [
          [nil, nil, nil, rook, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        expect(board.grid).to eq(expected)
      end

      it 'sends a command message to rook' do
        expect(rook).to receive(:update_position).with('D8')
        board.move_castle('C8')
      end
    end
  end

  describe '#all_enemies' do
    it 'returns an array of enemies on the board' do
      my_color = 'W'
      rook = Rook.new('B')
      bishop = Bishop.new('B')
      board.grid[2][3] = rook
      board.grid[3][3] = bishop
      result = board.all_enemies(my_color)
      expect(result).to contain_exactly(rook, bishop)
    end
  end

  describe '#all_allies' do
    it 'returns an array of allies on the board' do
      my_color = 'W'
      queen = Queen.new('W')
      knight = Knight.new('W')
      board.grid[4][5] = queen
      board.grid[2][2] = knight
      result = board.all_allies(my_color)
      expect(result).to contain_exactly(queen, knight)
    end
  end
end