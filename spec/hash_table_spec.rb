require 'spec_helper'

describe 'Hash Source' do
  it 'just works in a console' do
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | 1 | 2 | 3 |
      +---+---+---+
    TABLE
    {a: 1, b: 2, c: 3}.to_table.text_table.to_s.should == expected
  end
end