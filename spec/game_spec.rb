# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/pieces/rook'
require_relative '../lib/pieces/knight'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/pawn'
require_relative 'players/human_player_spec.rb'
require_relative 'players/computer_player_spec.rb'

RSpec.describe Game do
  subject(:game) { described_class.new }
  
  describe '#all_pieces' do
    it 'returns an array of all board pieces' do
      array = game.all_pieces
      expect(array).to include(a_kind_of(Pawn)).exactly(16).times
       .and include(a_kind_of(Rook)).exactly(4).times
       .and include(a_kind_of(Knight)).exactly(4).times
       .and include(a_kind_of(Bishop)).exactly(4).times
       .and include(a_kind_of(Queen)).twice
       .and include(a_kind_of(King)).twice
    end

    it 'creates pairs of pieces of the same kind' do
      array = game.all_pieces
      result = true
      i = 0
      until array[i].nil? do
        break result = false if array[i].class != array[i+1].class
        
        i += 2
      end
      expect(result).to be true
    end

    it 'initializes pieces that have no color, position and symbol attributes' do
      array = game.all_pieces
      result = array.all? do |piece|
        piece.color.nil? && piece.position.nil? && piece.symbol.nil?
      end
      expect(result).to be true
    end
  end

  describe '#change_player' do
    context 'if turn count is an odd number' do
      let(:player_white) { instance_double(HumanPlayer) }
      
      it 'changes @current_player to player_white' do
        game.instance_variable_set(:@player_white, player_white)
        game.turn_count = 1
        expect { game.change_player }.to change { game.current_player }.to(player_white)
      end
    end

    context 'if turn count is an even number' do
      let(:player_black) { instance_double(HumanPlayer) }
      
      it 'changes @current_player to player_black' do
        game.instance_variable_set(:@player_black, player_black)
        game.turn_count = 2
        expect { game.change_player }.to change { game.current_player }.to(player_black)
      end
    end
  end

  describe '#assign_players' do
    context 'when the player choose 1' do
      let(:p1) { instance_double(ComputerPlayer) }
      let(:p2) { instance_double(HumanPlayer) }

      before do
        allow(game).to receive(:choose_game_message)
        allow(game).to receive(:get_name)
        allow(game).to receive(:choice_one_or_two) { 1 }
        allow(ComputerPlayer).to receive(:new) { p1 }
        allow(HumanPlayer).to receive(:new) { p2 }
        allow_any_instance_of(Array).to receive(:shuffle) { [p1, p2] }
        allow(p1).to receive(:color=).with('B')
        allow(p2).to receive(:color=).with('W')
      end
      
      it 'assigns a ComputerPlayer to an instance variable' do
        game.assign_players
        expect(game.player_black).to eq(p1)
      end

      it 'assigns a HumanPlayer to an instance variable' do
        game.assign_players
        expect(game.player_white).to eq(p2)
      end
    end

    context 'when the player choose 2' do
      let(:p1) { instance_double(HumanPlayer) }
      let(:p2) { instance_double(HumanPlayer) }

      before do
        allow(game).to receive(:choose_game_message)
        allow(game).to receive(:get_name)
        allow(game).to receive(:choice_one_or_two) { 2 }
        allow(HumanPlayer).to receive(:new).and_return(p1, p2)
        allow_any_instance_of(Array).to receive(:shuffle) { [p1, p2] }
        allow(p1).to receive(:color=).with('B')
        allow(p2).to receive(:color=).with('W')
      end
      
      it 'assigns a HumanPlayer to @player_black' do
        game.assign_players
        expect(game.player_black).to eq(p1)
      end

      it 'assigns a HumanPlayer to @player_white' do
        game.assign_players
        expect(game.player_white).to eq(p2)
      end
    end
  end

  describe '#assign_attributes' do
    let(:rook1) { instance_double(Rook) }
    let(:rook2) { instance_double(Rook) }

    it 'sends a commange message to each piece' do
      allow(rook1).to receive(:color=)
      allow(rook2).to receive(:color=)
      expect([rook1, rook2]).to all(receive(:initial_positions_and_symbol))
      game.assign_attributes([rook1, rook2])
    end
    
    it 'assigns white color to pieces in even indices' do
      allow(rook1).to receive(:initial_positions_and_symbol)
      allow(rook2).to receive(:initial_positions_and_symbol)
      allow(rook2).to receive(:color=)
      expect(rook1).to receive(:color=).with('W')
      game.assign_attributes([rook1, rook2])
    end

    it 'assigns black color to pieces in oldd indices' do
      allow(rook1).to receive(:initial_positions_and_symbol)
      allow(rook2).to receive(:initial_positions_and_symbol)
      allow(rook1).to receive(:color=)
      expect(rook2).to receive(:color=).with('B')
      game.assign_attributes([rook1, rook2])
    end
  end

  describe '#game_over?' do
    let(:player) { instance_double(HumanPlayer, color: 'W') }
    let(:opponent) { instance_double(HumanPlayer, color: 'B') }
    let(:board) { instance_double(Board) }
    let(:checker) { instance_double(GameStatusChecker) }
    subject(:game) { described_class.new }

    before do
      game.instance_variable_set(:@board, board)
      game.instance_variable_set(:@current_player, player)
      game.instance_variable_set(:@player_white, player)
      game.instance_variable_set(:@player_black, opponent)
      game.instance_variable_set(:@turn_count, 8)
      allow(GameStatusChecker).to receive(:new) { checker }
      allow(checker).to receive(:stalemate?)
      allow(checker).to receive(:checkmate?)
    end
    
    it 'sends a command message to GameStatusChecker' do
      expect(GameStatusChecker).to receive(:new).with('W', board, 8)
      game.game_over?
    end

    context 'when the current player is stalemated' do
      before do
        allow(checker).to receive(:stalemate?) { true }
      end
    
      it 'does not update @winner' do
        expect {game.game_over?}.not_to change { game.winner }
      end
      
      it 'returns true' do
        expect(game.game_over?).to be true
      end
    end

    context 'when the current player is mated' do
      before do
        allow(checker).to receive(:checkmate?) { true }
      end
    
      it 'updates @winner to the opponent' do
        expect {game.game_over?}.to change { game.winner }.to(opponent)
      end
    
      it 'returns true' do
        expect(game.game_over?).to be true
      end
    end

    context 'when the current player is neither stalemated nor mated' do
      before do
        allow(checker).to receive(:stalemate?) { false }
        allow(checker).to receive(:checkmate?) { false }
      end
    
      it 'does not update @winner' do
        expect {game.game_over?}.not_to change { game.winner }
      end
    
      it 'returns false' do
        expect(game.game_over?).to be false
      end
    end
  end
end
