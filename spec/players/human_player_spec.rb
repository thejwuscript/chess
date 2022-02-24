# frozen_string_literal: true

require_relative '../../lib/players/human_player.rb'

RSpec.describe HumanPlayer do
  subject(:player) { described_class.new('human') }
  
  describe '#input' do
    context 'when player enters a valid input' do
      it 'returns the input' do
        allow(player).to receive(:gets).and_return('A6')
        result = player.input
        expect(result).to eq('A6')
      end

      it 'does not display invalid entry message' do
        allow(player).to receive(:gets).and_return('A6')
        expect(player).not_to receive(:invalid_input_message)
        player.input
      end
    end

    context 'when player enters invalid input twice' do
      it 'displays invalid entry message twice' do
        allow(player).to receive(:gets).and_return('KT', 'G0', 'D2')
        expect(player).to receive(:invalid_input_message).twice
        player.input
      end
    end
  end 
end