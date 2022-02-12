# frozen_string_literal: true

require_relative '../lib/game_status_checker'
require_relative '../lib/board'
require_relative '../lib/game'
require_relative '../lib/bishop'
require_relative '../lib/rook'
require_relative '../lib/king'

RSpec.describe GameStatusChecker do
  describe 'no_legal_moves?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:bishop1) { instance_double(Bishop) }
    let(:rook1) { instance_double(Rook) }
    let(:king) { instance_double(King) }
    color = 'W'
    subject(:no_more_moves) { described_class.new(color, board, game) }
    
    it 'sends a message #moves_available? to each ally piece on the board' do
      allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
      expect(bishop1).to receive(:moves_available?).with(board, game)
      expect(rook1).to receive(:moves_available?).with(board, game)
      expect(king).to receive(:moves_available?).with(board, game)
      no_more_moves.no_legal_moves?
    end
  
    context 'when a player cannot make any legal moves' do
      it 'returns true' do
        allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
        allow(bishop1).to receive(:moves_available?).with(board, game) { false }
        allow(rook1).to receive(:moves_available?).with(board, game) { false }
        allow(king).to receive(:moves_available?).with(board, game) { false }
        result = no_more_moves.no_legal_moves?
        expect(result).to be true
      end
    end

    context 'when a player can still make a legal move' do
      it 'returns false' do
        allow(board).to receive(:all_allies).with('W') { [bishop1, rook1, king] }
        allow(bishop1).to receive(:moves_available?).with(board, game) { false }
        allow(rook1).to receive(:moves_available?).with(board, game) { true }
        allow(king).to receive(:moves_available?).with(board, game) { false }
        result = no_more_moves.no_legal_moves?
        expect(result).to be false
      end
    end
  end

  describe '#own_king_in_check?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:bishop) { instance_double(Bishop, position: 'H1', color: 'W') }
    let(:rook) { instance_double(Rook, position: 'A5', color: 'W') }
    let(:king) { instance_double(King, color: 'B', position: 'C5') }
    let(:examiner1) { instance_double(MoveExaminer, validate_move: nil) }
    let(:examiner2) { instance_double(MoveExaminer, validate_move: 'C5') }
    color = 'B'
    subject(:king_checker) { described_class.new(color, board, game) }
    
    it 'sends a query message #all_enemies to @board' do
      allow(board).to receive(:find_own_king) { king }
      allow_any_instance_of(MoveExaminer).to receive(:validate_move)
      expect(board).to receive(:all_enemies).with('B') { [bishop, rook] }
      king_checker.own_king_in_check?
    end

    it 'sends a query message #find_own_king to @board' do
      allow(board).to receive(:all_enemies).with('B') { [bishop, rook] }
      allow_any_instance_of(MoveExaminer).to receive(:validate_move)
      expect(board).to receive(:find_own_king) { king }
      king_checker.own_king_in_check?
    end

    it 'sends message to 1 or more MoveExaminer till an enemy piece giving check is found' do
      allow(board).to receive(:find_own_king) { king }
      allow(board).to receive(:all_enemies).with('B') { [bishop, rook] }
      allow(MoveExaminer).to receive(:new).twice.and_return(examiner1, examiner2)
      expect(examiner1).to receive(:validate_move)
      expect(examiner2).to receive(:validate_move)
      king_checker.own_king_in_check?
    end

    it 'returns true if a MoveExaminer found an enemy piece giving check' do
      allow(board).to receive(:find_own_king) { king }
      allow(board).to receive(:all_enemies).with('B') { [bishop, rook] }
      allow(MoveExaminer).to receive(:new).twice.and_return(examiner1, examiner2)
      result = king_checker.own_king_in_check?
      expect(result).to be true
    end

    it 'returns false if no MoveExaminer found any enemy piece giving check' do
      allow(board).to receive(:find_own_king) { king }
      allow(board).to receive(:all_enemies).with('B') { [bishop] }
      allow(MoveExaminer).to receive(:new).and_return(examiner1)
      result = king_checker.own_king_in_check?
      expect(result).to be false
    end
  end
end