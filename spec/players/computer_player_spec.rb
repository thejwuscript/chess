# frozen_string_literal: true

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
      wrook = Rook.new('W', 'A1')
      wking = King.new('W', 'E1')
      
      before do
        grid = [
          [bqueen, nil, nil, nil, bking, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, bpawn, wpawn, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [wrook, nil, nil, nil, wking, nil, nil, nil]
        ]
        board.instance_variable_set(:@grid, grid)
        ai_player.instance_variable_set(:@color, 'W')
        allow_any_instance_of(MoveExaminer).to receive(:ally_king_exposed?) { false }
        allow_any_instance_of(MoveExaminer).to receive(:king_exposed?) { false }
        allow(bpawn).to receive(:double_step_turn) { 10 }
        allow(board).to receive(:deep_clone) { board.clone }
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
        allow(board).to receive(:deep_clone) { board.clone }
      end
    
      it 'returns the examiner with castling verified above all other examiners' do
        result = ai_player.choose_examiner(8)
        expect(result).to be_kind_of(MoveExaminer)
                      .and have_attributes(piece: wking, target: 'C1', castling_verified: true)
      end
    end
  end
end