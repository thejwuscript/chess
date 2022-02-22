# frozen_string_literal: true

require_relative '../lib/computer_player'
require_relative '../lib/board'
require_relative '../lib/game'
require_relative '../lib/rook'
require_relative '../lib/pawn'

RSpec.describe ComputerPlayer do
  describe '#all_possible_targets' do
    let(:board) { instance_double(Board) }
    let(:game) { instance_double(Game) }
    subject(:ai_player) { described_class.new('AI', 'B', board, game) }
    
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
    subject(:ai) { described_class.new('AI', 'B', board, game) }

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
end