# frozen_string_literal: true
RSpec::Matchers.define_negated_matcher :not_have_attributes, :have_attributes

require_relative '../../lib/players/computer_player'
require_relative '../../lib/board'
require_relative '../../lib/pieces/rook'
require_relative '../../lib/pieces/pawn'
require_relative '../../lib/pieces/queen'
require_relative '../../lib/pieces/king'
require_relative '../../lib/pieces/bishop'
require_relative '../../lib/pieces/knight'
require_relative '../../lib/game'

RSpec.describe ComputerPlayer do
  describe '#all_possible_targets' do
    let(:board) { instance_double(Board) }
    subject(:ai_player) { described_class.new('AI', board) }
    
    context 'when black has a rook and pawn that have moves available' do
      let(:rook) { instance_double(Rook, possible_targets: ['A2', 'B1']) }
      let(:pawn) { instance_double(Pawn, possible_targets: ['D5', 'E5']) }

      it 'returns a hash with pieces as keys and target positions as values' do
        allow(ai_player).to receive(:valid_pieces).and_return([rook, pawn])
        result = ai_player.all_possible_targets
        expected = {
          rook => ['A2', 'B1'],
          pawn => ['D5', 'E5']
        }
        expect(result).to eq(expected)
      end
    end
  end

  describe '#validated_examiners' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:rook) { instance_double(Rook) }
    let(:pawn) { instance_double(Pawn) }
    subject(:ai) { described_class.new('AI', board) }

    before do
      hash =  {
          rook => ['A2', 'B1'],
          pawn => ['D5', 'E5']
        }
      allow(ai).to receive(:all_possible_targets) { hash }
    end
    
    context 'when all target positions are valid as determined by MoveExaminer' do
      let(:examiner_A2) { instance_double(MoveExaminer, validate_move: 'A2') }
      let(:examiner_B1) { instance_double(MoveExaminer, validate_move: 'B1') }
      let(:examiner_D5) { instance_double(MoveExaminer, validate_move: 'D5') }
      let(:examiner_E5) { instance_double(MoveExaminer, validate_move: 'E5') }
      
      it 'returns an array containing examiners with all target positions' do
        allow(MoveExaminer).to receive(:new).exactly(4).times.and_return(examiner_A2, examiner_B1, examiner_D5, examiner_E5)
        result = ai.validated_examiners
        expected = [examiner_A2, examiner_B1, examiner_D5, examiner_E5]
        expect(result).to eq(expected)
      end
    end

    context 'when one or more target positions are not valid as determined by MoveExaminer' do
      let(:examiner_A2) { instance_double(MoveExaminer, validate_move: 'A2') }
      let(:examiner_B1) { instance_double(MoveExaminer, validate_move: nil) }
      let(:examiner_D5) { instance_double(MoveExaminer, validate_move: 'D5') }
      let(:examiner_E5) { instance_double(MoveExaminer, validate_move: nil) }

      it 'returns an array containing only the examiners with valid target positions' do
        allow(MoveExaminer).to receive(:new).exactly(4).times.and_return(examiner_A2, examiner_B1, examiner_D5, examiner_E5)
        result = ai.validated_examiners
        expect(result).to eq( [examiner_A2, examiner_D5] )
      end
    end
  end

  describe '#choose_examiner' do
    board = Board.new
    subject(:ai_player) { described_class.new('AI', board) }
    
    context 'when en-passant move is available' do
      bqueen = Queen.new('B', 'A8')
      bking = King.new('B', 'E8')
      bpawn = Pawn.new('B', 'D5')
      wpawn = Pawn.new('W', 'E5')
      wrook = Rook.new('W', 'A2')
      wking = King.new('W', 'E1')
      
      before do
        grid = [
          [bqueen, nil, nil, nil, bking, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, bpawn, wpawn, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [wrook, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, wking, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        ai_player.instance_variable_set(:@color, 'W')
        allow_any_instance_of(MoveExaminer).to receive(:ally_king_exposed?) { false }
        allow_any_instance_of(MoveExaminer).to receive(:king_exposed?) { false }
        allow(bpawn).to receive(:double_step_turn) { 10 }
      end
    
      it 'returns the examiner with pawn and en-passant verified above all other examiners' do
        result = ai_player.choose_examiner(11)
        expect(result).to be_kind_of(MoveExaminer)
                      .and have_attributes(piece: wpawn, target: 'D6', en_passant_verified: true)
      end
    end

    context 'when castling is available' do
      bqueen = Queen.new('B', 'A8')
      bking = King.new('B', 'E8')
      bpawn = Pawn.new('B', 'D5')
      wpawn = Pawn.new('W', 'D4')
      wrook = Rook.new('W', 'A1')
      wking = King.new('W', 'E1')
      
      before do
        grid = [
          [bqueen, nil, nil, nil, bking, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, bpawn, nil, nil, nil, nil],
          [nil, nil, nil, wpawn, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [wrook, nil, nil, nil, wking, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        ai_player.instance_variable_set(:@color, 'W')
        allow_any_instance_of(MoveExaminer).to receive(:ally_king_exposed?) { false }
        allow_any_instance_of(MoveExaminer).to receive(:king_exposed?) { false }
        allow_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?) { true }
      end
    
      it 'returns the examiner with castling verified above all other examiners' do
        result = ai_player.choose_examiner(8)
        expect(result).to be_kind_of(MoveExaminer)
                      .and have_attributes(piece: wking, castling_verified: true)
      end
    end

    context 'when a promote can capture another promote attacking but it would sacrifice itself' do
      
      bqueen = Queen.new('B', 'A8')
      bking = King.new('B', 'B8')
      bpawn = Pawn.new('B', 'D5')
      wpawn = Pawn.new('W', 'D4')
      wrook = Rook.new('W', 'A1')
      wking = King.new('W', 'E1')

      before do
        grid = [
          [bqueen, bking, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, bpawn, nil, nil, nil, nil],
          [nil, nil, nil, wpawn, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [wrook, nil, nil, nil, wking, nil, nil, nil]
        ]
        ai_player.instance_variable_set(:@color, 'W')
        board.instance_variable_set(:@grid, grid)
        allow_any_instance_of(MoveExaminer).to receive(:ally_king_exposed?) { false }
        allow_any_instance_of(MoveExaminer).to receive(:king_exposed?) { false }
        allow_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?) { false }
      end
    
      it 'does not return the examiner with the capturing move' do
        result = ai_player.choose_examiner(8)
        expect(result).not_to have_attributes(target: 'A8')
      end

      it 'does not return examiners with moves that puts self under attack still' do
        result = ai_player.choose_examiner(14)
        expect(result).to not_have_attributes(target: 'A7')
                      .or not_have_attributes(target: 'A6')
                      .or not_have_attributes(target: 'A5')
                      .or not_have_attributes(target: 'A4')
                      .or not_have_attributes(target: 'A3')
                      .or not_have_attributes(target: 'A2')
      end

      it 'returns an examiner with a move that prevents capture' do
        result = ai_player.choose_examiner(12)
        expect(result).to have_attributes(target: 'B1')
                      .or have_attributes(target: 'C1')
                      .or have_attributes(target: 'D1')
      end
    end

    context 'when the queen is under attack, queen cannot sacrifice herself but another piece can protect the queen' do
      bking = King.new('B', 'G8')
      brook1 = Rook.new('B', 'F8')
      brook2 = Rook.new('B', 'F1')
      wbishop = Bishop.new('W', 'A5')
      wking = King.new('W', 'C1')
      wqueen = Queen.new('W', 'D1')

      before do
        grid = [
          [nil, nil, nil, nil, nil, brook1, bking, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [wbishop, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, wking, wqueen, nil, brook2, nil, nil]
        ]
        ai_player.instance_variable_set(:@color, 'W')
        board.instance_variable_set(:@grid, grid)
      end
      
      it 'returns the examiner with the move to protect the queen despite risking the piece' do
        result = ai_player.choose_examiner(11)
        expect(result).to be_kind_of(MoveExaminer)
                      .and have_attributes(piece: wbishop, target: 'E1')
      end
    end

    context 'when the queen cannot escape from being captured' do
      wking = King.new('W', 'A2')
      wqueen = Queen.new('W', 'G1')
      bqueen = Queen.new('B', 'B4')
      bbishop1 = Bishop.new('B', 'E3')
      bking = King.new('B', 'E2')
      bknight = Knight.new('B', 'F1')
      bbishop2 = Bishop.new('B', 'G2')
      brook1 = Rook.new('B', 'H2')
      brook2 = Rook.new('B', 'H1')

      before do
        grid = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, bqueen, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, bbishop1, nil, nil, nil],
          [wking, nil, nil, nil, bking, nil, bbishop2, brook1],
          [nil, nil, nil, nil, nil, bknight, wqueen, brook2]
        ]
        ai_player.instance_variable_set(:@color, 'W')
        board.instance_variable_set(:@grid, grid)
      end
    
      it 'returns an examiner that has any legal move on the board' do
        result = ai_player.choose_examiner(17)
        expect(result).to have_attributes(piece: wking, target: 'A1')
                      .or have_attributes(piece: wqueen, target: 'F1')
                      .or have_attributes(piece: wqueen, target: 'F2')
                      .or have_attributes(piece: wqueen, target: 'E3')
                      .or have_attributes(piece: wqueen, target: 'G2')
                      .or have_attributes(piece: wqueen, target: 'H2')
                      .or have_attributes(piece: wqueen, target: 'H1')
      end
    end

    context 'when an ally piece can give check' do
      bking = King.new('B', 'C8')
      wking = King.new('W', 'C1')
      brook = Rook.new('B', 'F5')

      before do
        grid = [
          [nil, nil, bking, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, brook, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, wking, nil, nil, nil, nil, nil]
        ]
        ai_player.instance_variable_set(:@color, 'B')
        board.instance_variable_set(:@grid, grid)
      end
      it 'returns the examiner with the move that gives check' do
        result = ai_player.choose_examiner(18)
        expect(result).to have_attributes(piece: brook, target: 'F1')
                      .or have_attributes(piece: brook, target: 'C5')
      end
    end
  end
end