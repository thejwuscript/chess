# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'
require_relative '../lib/pawn'

RSpec.describe Game do
  subject(:game) { described_class.new }
  
  describe '#create_all_pieces' do
    
    before do
      game.create_all_pieces
    end
  
    it 'stores an array of all board pieces in @all_pieces' do
      expect(game.all_pieces).to include(a_kind_of(Pawn)).exactly(16).times
       .and include(a_kind_of(Rook)).exactly(4).times
       .and include(a_kind_of(Knight)).exactly(4).times
       .and include(a_kind_of(Bishop)).exactly(4).times
       .and include(a_kind_of(Queen)).twice
       .and include(a_kind_of(King)).twice
    end

    it 'creates pairs of the same class from the beginning' do
      result = true
      i = 0
      until game.all_pieces[i].nil? do
        break result = false if game.all_pieces[i].class != game.all_pieces[i+1].class
        
        i += 2
      end
      expect(result).to be true
    end

    it 'initializes pieces that have no color, position and symbol attributes' do
      result = game.all_pieces.all? do |piece|
        piece.color.nil? && piece.position.nil? && piece.symbol.nil?
      end
    expect(result).to be true
    end
  end

  describe '#select_piece' do
  end

  describe '#player_input' do
    context 'when player enters a valid input' do
      before do
        allow(game).to receive(:enter_input_message)
      end
    
      it 'returns the input' do
        allow(game).to receive(:gets).and_return('A6')
        result = game.player_input
        expect(result).to eq('A6')
      end

      it 'does not display invalid entry message' do
        allow(game).to receive(:gets).and_return('A6')
        expect(game).not_to receive(:invalid_input_message)
        game.player_input
      end
    end

    context 'when player enters invalid input twice' do
      before do
        allow(game).to receive(:enter_input_message)
      end

      it 'displays invalid entry message twice' do
        allow(game).to receive(:gets).and_return('KT', 'G0', 'D2')
        expect(game).to receive(:invalid_input_message).twice
        game.player_input
      end
    end
  end 

end
