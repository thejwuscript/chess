#frozen_string_literal: true

RSpec.shared_examples 'shared #position_to_array' do
    it "converts the piece's position to a two-element array" do
      subject.position = 'G7'
      result = subject.position_to_array
      expect(result).to eql([1, 6])
    end
end

RSpec.shared_examples 'shared #generate_coordinates' do |param|
  it 'responds to #generate_coordinates' do
    expect(subject).to respond_to(:generate_coordinates)
  end

  it 'returns all coordinates the piece can move to' do
    result = subject.generate_coordinates
    expect(result).to eq(param)
  end
end

RSpec.shared_examples 'shared #possible_targets' do |param|
  it 'returns all possible target positions for a piece' do
    result = subject.possible_targets
    expect(result).to eq(param)
  end
end