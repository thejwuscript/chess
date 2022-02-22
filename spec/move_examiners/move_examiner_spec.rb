# frozen_string_literal: true

require_relative '../../lib/move_examiners/move_examiner'
require_relative '../../lib/board'
require_relative '../../lib/game'
require_relative '../../lib/move_examiners/en_passant_checker'
require_relative '../../lib/pieces/king'
require_relative '../../lib/pieces/pawn'

RSpec.describe MoveExaminer do
  let(:board) { instance_double(Board) }
  let(:piece) { double('piece') }
  let(:game) { instance_double(Game) }

  describe '#initialize' do
    subject(:initial_examiner) { described_class.new(board, piece, 'D3') }

    before do
      allow(piece).to receive(:position).and_return('A8')
    end
  
    it 'stores [0, 0] in @start_ary when position of piece is A8' do
      result = initial_examiner.start_ary
      expect(result).to eq([0, 0])
    end

    it 'stores [5, 3] in @target_ary when the target is D3' do
      result = initial_examiner.target_ary
      expect(result).to eq([5, 3])
    end
  end

  describe '#recursive_search' do
    subject(:depth_examiner) { described_class.new(board, piece, 'A3') }

    before do
      allow(piece).to receive(:position) { 'A8' }
      allow(piece).to receive(:within_limits?) { true }
    end
    
    context 'when the path from A8 to A3 is clear' do
      it 'returns [5, 0]' do
        manner = [1, 0]
        allow(board).to receive(:occupied?).and_return(false).exactly(4).times
        start_ary = depth_examiner.start_ary
        target_ary = depth_examiner.target_ary
        result = depth_examiner.send(:recursive_search, start_ary, manner, target_ary)
        expect(result).to eql([5, 0])
      end
    end

    context 'when a piece is blocking the path from [0, 0] to [5, 0]' do
      it 'returns nil' do
        manner = [1, 0]
        allow(board).to receive(:occupied?).and_return(false, false, true)
        start_ary = depth_examiner.start_ary
        target_ary = depth_examiner.target_ary
        result = depth_examiner.send(:recursive_search, start_ary, manner, target_ary)
        expect(result).to be_nil
      end
    end
  end

  describe '#breadth_search' do
    subject(:breadth_examiner) {described_class.new(board, piece, 'E3') }
    
    context 'when a piece is making a move from G2 to E3 unhindered' do
      before do
        allow(piece).to receive(:position).and_return('G2')
        allow(piece).to receive(:move_manner).and_return([[1, 2], [2, 1], [-1, -2]])
        allow(piece).to receive(:within_limits?) { true }
      end
      
      it 'returns [5, 4]' do
        result = breadth_examiner.send(:breadth_search)
        expect(result).to eql([5, 4])
      end

      it 'loops through manners array until the target array is found' do
        expect(piece).to receive(:within_limits?).exactly(3).times
        breadth_examiner.send(:breadth_search)
      end
    end
  end

  describe '#pawn_move_search' do
    subject(:pawn_move_examiner) { described_class.new(board, piece, 'B4', game) }
    
    context 'when a white pawn is moving from B2 to B4' do
      
      before do
        allow(piece).to receive(:position).and_return('B2')
        allow(piece).to receive(:color).and_return('W')
        allow(pawn_move_examiner).to receive(:double_step?).and_return(true)
      end
    
      it 'returns [4, 1] when unobstructed' do
        allow(board).to receive(:occupied?).and_return(false, false)
        result = pawn_move_examiner.send(:pawn_move_search)
        expect(result).to eq([4, 1])
      end

      it 'returns nil when obstructed' do
        allow(board).to receive(:occupied?).and_return(false, true)
        result = pawn_move_examiner.send(:pawn_move_search)
        expect(result).to be_nil
      end
    end
  end

  describe '#pawn_attack' do
    subject(:pawn_attack_examiner) { described_class.new(board, piece, 'F4', game) }

    before do
      allow(piece).to receive(:position) { 'E3' }
      allow(piece).to receive(:color) { 'W' }
    end
  
    it 'returns nil when the move is not an attacking move' do
      pawn_attack_examiner.instance_variable_set(:@target, 'A3')
      pawn_attack_examiner.instance_variable_set(:@target_ary, [5, 0])
      result = pawn_attack_examiner.send(:pawn_attack_search)
      expect(result).to be_nil
    end

    it 'returns target_ary if the attacking spot is occupied' do
      allow(board).to receive(:occupied?) { true }
      result = pawn_attack_examiner.send(:pawn_attack_search)
      expect(result).to eq([4, 5])
    end

    it 'sends #check_en_passant when the attacking spot is empty' do
      allow(board).to receive(:occupied?) { false }
      expect(pawn_attack_examiner).to receive(:check_en_passant)
      pawn_attack_examiner.send(:pawn_attack_search)
    end
  end

  describe '#check_en_passant' do
    subject(:pawn_examiner) { described_class.new(board, piece, 'D6') }
    
    before do
      allow(piece).to receive(:position) { 'E5'}
    end

    it 'sends a query message to EnPassantChecker' do
      expect_any_instance_of(EnPassantChecker).to receive(:valid_capture_condition?)
      pawn_examiner.send(:check_en_passant)
    end

    it "returns target_ary if en passant condition is met" do
      allow_any_instance_of(EnPassantChecker).to receive(:valid_capture_condition?).and_return(true)
      result = pawn_examiner.send(:check_en_passant)
      expect(result).to eq([2, 3])
    end

    it "returns nil if en passant condition is not met" do
      allow_any_instance_of(EnPassantChecker).to receive(:valid_capture_condition?).and_return(false)
      result = pawn_examiner.send(:check_en_passant)
      expect(result).to be_nil
    end

    it 'updates @en_passant to true if condition is met' do
      allow_any_instance_of(EnPassantChecker).to receive(:valid_capture_condition?).and_return(true)
      expect { pawn_examiner.send(:check_en_passant) }.to change { pawn_examiner.en_passant_verified }.to true
    end
  end

  describe '#king_search' do
    context 'when the king has not moved from the starting point and tries to move two steps horizontally' do
      subject(:two_steps_examiner) { described_class.new(board, piece, 'G1') }
      
      it 'sends a message to self to validate castling' do
        allow(piece).to receive(:position) { 'E1' }
        allow(piece).to receive(:move_count) { 0 }
        expect(two_steps_examiner).to receive(:validate_castling)
        two_steps_examiner.send(:king_search)
      end
    end

    context 'when the king does not move in a castling-like behavior' do
      subject(:king_examiner) { described_class.new(board, piece, 'D2') }
      
      it 'sends #breadth_search to self' do
        allow(piece).to receive(:position) { 'E1' }
        allow(piece).to receive(:move_count) { 0 }
        expect(king_examiner).to receive(:breadth_search)
        king_examiner.send(:king_search)
      end
    end

    context 'when the king has moved once or more' do
      subject(:moved_king_examiner) { described_class.new(board, piece, 'C1') }

      it 'sends #bredth_search to self' do
        allow(piece).to receive(:position) { 'E1' }
        allow(piece).to receive(:move_count) { 1 }
        expect(moved_king_examiner).to receive(:breadth_search)
        moved_king_examiner.send(:king_search)
      end
    end
  end

  describe '#validate_castling' do
    subject(:castling_examiner) { described_class.new(board, piece, 'G1') }
    let(:castling_checker) { instance_double(CastlingChecker) }
    
    it 'instantiates CastlingChecker' do
      allow(piece).to receive(:position) { 'E1' }
      allow(castling_checker).to receive(:meet_castling_condition?)
      expect(CastlingChecker).to receive(:new).with(board, piece, [7, 6]) { castling_checker }
      castling_examiner.send(:validate_castling)
    end

    it 'sends a query message to CastlingChecker' do
      allow(piece).to receive(:position) { 'E1' }
      expect_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?)
      castling_examiner.send(:validate_castling)
    end

    it 'returns target_ary if castling conditions are met' do
      allow(piece).to receive(:position) { 'E1' }
      allow_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?).and_return(true)
      result = castling_examiner.send(:validate_castling)
      expect(result).to eq([7, 6])
    end

    it 'returns nil if castling conditions are not met' do
      allow(piece).to receive(:position) { 'E1' }
      allow_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?).and_return(false)
      result = castling_examiner.send(:validate_castling)
      expect(result).to be_nil
    end

    it 'updates @castling when conditions are met' do
      allow(piece).to receive(:position) { 'E1' }
      allow_any_instance_of(CastlingChecker).to receive(:meet_castling_condition?).and_return(true)
      expect { castling_examiner.send(:validate_castling) }.to change { castling_examiner.castling_verified }.to true
    end
  end

  describe 'own_king_exposed?' do
    let(:piece) { instance_double(King, is_a?: King, color: 'W') }
    let(:enemy) { instance_double(King, is_a?: King, color: 'B', position: 'E5') }
    let(:board) { instance_double(Board) }
    let(:clone) { instance_double(Board) }
    subject(:exposed_king_examiner) { described_class.new(board, piece, 'E4') }
    
    it 'sends board a message to move the piece to target' do
      allow(piece).to receive(:position).and_return('E3')
      allow(clone).to receive(:find_own_king_in_check).with('W')
      expect(clone).to receive(:move_piece_to_target).with('E4', piece)
      exposed_king_examiner.send(:king_exposed?, clone)
    end

    it 'sends board a message to retreive king in check, if any' do
      allow(board).to receive(:move_piece_to_target)
      allow(piece).to receive(:position).and_return('E4')
      expect(board).to receive(:find_own_king_in_check).with('W')
      exposed_king_examiner.send(:king_exposed?)
    end

    it 'it returns true if own king would be in check' do
      allow(board).to receive(:move_piece_to_target)
      allow(piece).to receive(:position).and_return('E4')
      allow(board).to receive(:find_own_king_in_check).with('W').and_return(piece)
      result = exposed_king_examiner.send(:king_exposed?)
      expect(result).to be true
    end
  end

  describe '#search_target' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    let(:piece) { instance_double(Pawn) }
    subject(:search_examiner) { described_class.new(board, piece, 'E4', game) }
    
    context 'when piece is a Pawn' do
      it 'calls #pawn_attack_search' do 
      end
    end
  end
end
