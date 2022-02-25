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

  describe '#save_board_info' do
    it 'sends .open to File' do
      expect(File).to receive(:open)
      game.save_board_info
    end

    it 'dumps a hash' do
      expect(YAML).to receive(:dump)
      game.save_board_info
    end

    it 'writes the serialized hash in a file' do
      expect_any_instance_of(File).to receive(:write)
      game.save_board_info
    end
  end

  describe '#round' do
    context 'when #game_over? returns false, false then true' do
      before do
        allow(game).to receive(:game_over?).and_return(false, false, true)
      end
    
      it 'calls #update_turn_count three times' do
        allow(game).to receive(:player_turn)
        expect(game).to receive(:update_turn_count).exactly(3).times
        game.round
      end

      it 'calls #change_player three times' do
        allow(game).to receive(:player_turn)
        expect(game).to receive(:change_player).exactly(3).times
        game.round
      end

      it 'calls #player_turn twice' do
        expect(game).to receive(:player_turn).twice
        game.round
      end
    end
  end

  describe '#computer_move' do
    let(:player) { instance_double(ComputerPlayer) }
    let(:examiner) { instance_double(MoveExaminer, piece: nil) }

    before do
      board = game.instance_variable_get(:@board)
      allow(board).to receive(:show_color_guides)
      allow(player).to receive(:choose_examiner) { examiner }
      game.instance_variable_set(:@current_player, player)
    end

    it 'returns a MoveExaminer' do
      result = game.computer_move
      expect(result).to eq(examiner)
    end

    it 'sends #show_color_guides to board' do
      board = game.instance_variable_get(:@board)
      expect(board).to receive(:show_color_guides)
      game.computer_move
    end
  end

  describe '#select_piece' do
    let(:player) { instance_double(HumanPlayer) }

    before do
      allow(game).to receive(:choose_piece_message)
      allow(game).to receive(:invalid_input_message)
      allow(game).to receive(:valid_selection?) { true }
      game.instance_variable_set(:@current_player, player)
    end
    
    it "sends board a message with player's input as argument" do
      board = game.instance_variable_get(:@board)
      allow(player).to receive(:input) { 'G4' }
      expect(board).to receive(:piece_at).with('G4')
      game.select_piece
    end

    it 'calls #save_game when input is S' do
      board = game.instance_variable_get(:@board)
      allow(player).to receive(:input).and_return('S', 'F3')
      expect(game).to receive(:save_game)
      game.select_piece
    end

    it 'calls #exit_game when input is Q' do
      board = game.instance_variable_get(:@board)
      allow(player).to receive(:input).and_return('Q', 'B1')
      expect(game).to receive(:exit_game)
      game.select_piece
    end

    it 'calls #invalid_input_message twice when selection is invalid twice' do
      board = game.instance_variable_get(:@board)
      allow(player).to receive(:input).and_return('99', 'J8', 'F6')
      allow(game).to receive(:valid_selection?).and_return(false, false, true)
      expect(game).to receive(:invalid_input_message).twice
      game.select_piece
    end
  end

  describe '#player_target' do
    let(:examiner1) { instance_double(MoveExaminer, piece: nil, target: 'E2') }
    let(:examiner2) { instance_double(MoveExaminer, piece: nil, target: 'D8') }
    let(:player) { instance_double(HumanPlayer) }

    before do
      allow(game).to receive(:choose_move_message)
      game.instance_variable_set(:@current_player, player)
    end
    
    it "returns the examiner whose target matches the player's input" do
      allow(player).to receive(:input) { 'D8' }
      examiners = [examiner1, examiner2]
      result = game.player_target(examiners)
      expect(result).to eq(examiner2)
    end

    it 'calls #undo when player enters B' do
      allow(player).to receive(:input) { 'B' }
      examiners = [examiner1, examiner2]
      expect(game).to receive(:undo)
      game.player_target(examiners)
    end

    it "calls #invalid_input_message until the input matches one of examiner's target" do
      allow(player).to receive(:input).and_return('UJ', 'E1', 'E2')
      examiners = [examiner1, examiner2]
      expect(game).to receive(:invalid_input_message).twice
      game.player_target(examiners)
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
      allow(board).to receive(:pawn_positions)
      allow(board).to receive(:number_of_pieces)
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

  describe '#pawn_promotion' do
    let(:pawn) { instance_double(Pawn, color: 'W', position: 'G8') }
    let(:player) { instance_double(HumanPlayer) }

    before do
      allow(game.board).to receive(:promotion_candidate) { pawn }
      game.instance_variable_set(:@current_player, player)
      allow(game).to receive(:set_new_promoted_piece)
      allow(game.board).to receive(:show_board)
    end

    context 'a pawn is ready to promote and when user chooses one' do
      it 'instantiates Queen' do
        allow(player).to receive(:promotion_choice) { 1 }
        expect(Queen).to receive(:new).with('W', 'G8')
        game.pawn_promotion
      end
    end

    context 'a pawn is ready to promote and when user chooses two' do
      it 'instantiates Rook' do
        allow(player).to receive(:promotion_choice) { 2 }
        expect(Rook).to receive(:new).with('W', 'G8')
        game.pawn_promotion
      end
    end

    context 'a pawn is ready to promote and when user chooses three' do
      it 'instantiates Bishop' do
        allow(player).to receive(:promotion_choice) { 3 }
        expect(Bishop).to receive(:new).with( 'W', 'G8')
        game.pawn_promotion
      end
    end

    context 'a pawn is ready to promote and when user chooses four' do
      it 'instantiates Knight' do
        allow(player).to receive(:promotion_choice) { 4 }
        expect(Knight).to receive(:new).with('W', 'G8')
        game.pawn_promotion
      end
    end
  end
end
