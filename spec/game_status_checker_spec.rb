# frozen_string_literal: true

require_relative '../lib/game_status_checker'
require_relative '../lib/board'
require_relative '../lib/game'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/rook'
require_relative '../lib/pieces/king'

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
    color = 'B'
    let(:enemy1) { instance_double(Bishop, position: 'H1', color: 'W') }
    let(:enemy2) { instance_double(Rook, position: 'A5', color: 'W') }
    subject(:king_checker) { described_class.new(color, board, game) }

    it 'sends a query message to board' do
      expect(board).to receive(:enemies_giving_check).with('B', nil) { [enemy1, enemy2] }
      king_checker.own_king_in_check?
    end

    it 'returns true if the message to board returns a non-empty array' do
      allow(board).to receive(:enemies_giving_check).with('B', nil) { [enemy1, enemy2] }
      result = king_checker.own_king_in_check?
      expect(result).to be true
    end

    it 'returns false if the message to board returns an empty array' do
      allow(board).to receive(:enemies_giving_check).with('B', nil) { [] }
      result = king_checker.own_king_in_check?
      expect(result).to be false
    end
  end

  describe '#no_counterattack?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:enemy_rook) { instance_double(Rook, position: 'B3') }
    let(:enemy_bishop) {instance_double(Bishop, position: 'B6') }
    let(:ally_rook) { instance_double(Rook, position: 'H8') }
    let(:own_king) { instance_double(King, position: 'E3') }
    let(:examiner1) { instance_double(MoveExaminer, validate_move: nil) }
    let(:examiner2) { instance_double(MoveExaminer, validate_move: nil) }
    color = 'W'
    subject(:counterattack_checker) { described_class.new(color, board, game) }

    before do
      allow(board).to receive(:enemies_giving_check).with('W') { [enemy_rook, enemy_bishop] }
      allow(board).to receive(:all_allies).with('W') { [ally_rook, own_king] }
      allow(MoveExaminer).to receive(:new).and_return(examiner1, examiner2)
    end
  
    it 'sends message #enemies_giving_check to board' do
      expect(board).to receive(:enemies_giving_check).with('W')
      counterattack_checker.no_counterattack?
    end

    it 'sends message #all_allies to board' do
      expect(board).to receive(:all_allies).with('W')
      counterattack_checker.no_counterattack?
    end

    it 'instantiates MoveExaminer at least once' do
      expect(MoveExaminer).to receive(:new)
      counterattack_checker.no_counterattack?
    end
  
    context 'when all allies cannot capture the enemy pieces giving check' do
      it 'returns true' do
        result = counterattack_checker.no_counterattack?
        expect(result).to be true
      end
    end

    context 'when one or more allies can capture the enemy pieces giving check' do
      it 'returns false' do
        allow(own_king).to receive(:position) { 'C3' }
        allow(examiner2).to receive(:validate_move) { 'B3' }
        result = counterattack_checker.no_counterattack?
        expect(result).to be false
      end
    end
  end

  describe '#stalemate?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    color = 'W'
    
    context 'when no legal moves left, no counterattacks and own king is not in check' do
      subject(:yes_stalemate) { described_class.new(color, board, game) }

      it 'returns true' do
        allow(yes_stalemate).to receive(:no_legal_moves?) { true }
        allow(yes_stalemate).to receive(:no_counterattack?) { true }
        allow(yes_stalemate).to receive(:own_king_in_check?) { false }
        result = yes_stalemate.stalemate?
        expect(result).to be true
      end
    end

    context 'when any of the three conditions above is not met' do
      subject(:no_stalemate) { described_class.new(color, board, game) }

      it 'returns false' do
        allow(no_stalemate).to receive(:no_legal_moves?) { true }
        allow(no_stalemate).to receive(:no_counterattack?) { true }
        allow(no_stalemate).to receive(:own_king_in_check?) { true }
        result = no_stalemate.stalemate?
        expect(result).to be false
      end
    end
  end

  describe 'checkmate?' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    color = 'W'
    
    context 'when no legal moves left, no counterattacks and own king is in check' do
      subject(:yes_checkmate) { described_class.new(color, board, game) }
      
      it 'returns true' do
        allow(yes_checkmate).to receive(:no_legal_moves?) { true }
        allow(yes_checkmate).to receive(:no_counterattack?) { true }
        allow(yes_checkmate).to receive(:own_king_in_check?) { true }
        result = yes_checkmate.checkmate?
        expect(result).to be true
      end
    end

    context 'when any of the three conditions above is not met' do
      subject(:no_checkmate) { described_class.new(color, board, game) }
      
      it 'returns false' do
        allow(no_checkmate).to receive(:no_legal_moves?) { true }
        allow(no_checkmate).to receive(:no_counterattack?) { true }
        allow(no_checkmate).to receive(:own_king_in_check?) { false }
        result = no_checkmate.checkmate?
        expect(result).to be false
      end
    end
  end
end
