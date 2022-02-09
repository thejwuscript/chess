#frozen_string_literal: true

require_relative '../lib/en_passant_checker'
require_relative '../lib/game'
require_relative '../lib/pawn'
require_relative '../lib/board'

RSpec.describe EnPassantChecker do
  let(:board) { instance_double(Board) }
  let(:pawn) { instance_double(Pawn, color: 'W') }
  let(:enemy) { instance_double(Pawn, is_a?: Pawn, color: 'B') }
  let(:game) { instance_double(Game) }
  subject(:checker) { described_class.new(board, pawn, [2, 7], game) }
  
  describe '#locate_enemy_pawn' do
    context 'when an enemy pawn is found' do
      it 'returns the enemy pawn to be evaluated for en passant capture' do
        allow(board).to receive(:grid) {
          [[], [], [], [nil, nil, nil, nil, nil, nil, nil, enemy], [], [], [], []] 
          }
        result = checker.locate_enemy_pawn
        expect(result).to eq(enemy)
      end
    end
  end
end