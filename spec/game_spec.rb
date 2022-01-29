# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/queen'
require_relative '../lib/king'
require_relative '../lib/pawn'
require_relative '../lib/player'

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

  describe '#player_input' do
    context 'when player enters a valid input' do
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
      it 'displays invalid entry message twice' do
        allow(game).to receive(:gets).and_return('KT', 'G0', 'D2')
        expect(game).to receive(:invalid_input_message).twice
        game.player_input
      end
    end
  end 

  describe '#change_player' do
    context 'if turn count is an odd number' do
      let(:player_white) { instance_double(Player) }
      
      it 'changes @current_player to player_white' do
        game.instance_variable_set(:@player_white, player_white)
        game.turn_count = 1
        expect { game.change_player }.to change { game.current_player }.to(player_white)
      end
    end

    context 'if turn count is an even number' do
      let(:player_black) { instance_double(Player) }
      
      it 'changes @current_player to player_black' do
        game.instance_variable_set(:@player_black, player_black)
        game.turn_count = 2
        expect { game.change_player }.to change { game.current_player }.to(player_black)
      end
    end
  end

  describe '#assign_players' do
    context 'when two names in an array are provided' do
      before do
        array = ['Bob', 'Jane']
        allow(game).to receive(:player_names).and_return(array)
        allow(array).to receive(:shuffle).and_return(array)
        allow(Player).to receive(:new).twice
      end
      
      it 'assigns color white to the player of first element' do
        expect(Player).to receive(:new).with('Bob', 'W')
        game.assign_players
      end

      it 'assigns color black to the player of last element' do
        expect(Player).to receive(:new).with('Jane', 'B')
        game.assign_players
      end
    end
  end

  describe '#promote_pawn' do
    context 'when a white pawn can be promoted' do
      white_pawn = Pawn.new('W', 'C8')
      
      it 'is replaced by a Queen' do
        allow(game.board).to receive(:promote_candidate).and_return(white_pawn)
        allow(game).to receive(:promotion_choice).and_return(1)
        game.promote_pawn
        result = game.board.grid[0][2]
        expect(result).to be_kind_of(Queen)
      end
    end
  end
end
