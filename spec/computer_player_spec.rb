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
end