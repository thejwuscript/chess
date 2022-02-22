# frozen_string_literal: true

require_relative '../../lib/move_examiners/en_passant_checker'
require_relative '../../lib/game'
require_relative '../../lib/pieces/pawn'
require_relative '../../lib/board'

RSpec.describe EnPassantChecker do
  let(:board) { instance_double(Board) }
  let(:pawn) { instance_double(Pawn, color: 'W') }
  let(:enemy) { instance_double(Pawn, is_a?: Pawn, color: 'B') }
  let(:game) { instance_double(Game) }
  subject(:checker) { described_class.new(board, pawn, [2, 7], game) }
  
  describe '#locate_enemy_pawn' do
    context 'when an enemy pawn is found at the capturing spot' do
      it 'returns the enemy pawn to be evaluated for en passant capture' do
        allow(board).to receive(:grid) {
          [[], [], [], [nil, nil, nil, nil, nil, nil, nil, enemy], [], [], [], []] 
          }
        result = checker.send(:locate_enemy_pawn)
        expect(result).to eq(enemy)
      end
    end

    context 'when there is no enemy pawn to be found at the capturing spot' do
      it 'returns nil' do
        allow(board).to receive(:grid) {
          [[], [], [], [nil, nil, nil, enemy, nil, nil, nil, nil], [], [], [], []] 
          }
        result = checker.send(:locate_enemy_pawn)
        expect(result).to be_nil
      end
    end
  end

  describe '#validate_capture_condition' do
    it 'sends a query message to enemy pawn' do
      allow(checker).to receive(:locate_enemy_pawn) { enemy }
      expect(enemy).to receive(:en_passantable?).with('B', game)
      checker.valid_capture_condition?
    end

    it 'does not send a message to enemy pawn if there is no enemy pawn' do
      allow(checker).to receive(:locate_enemy_pawn)
      expect(enemy).not_to receive(:en_passantable?)
      checker.valid_capture_condition?
    end
  end
end
