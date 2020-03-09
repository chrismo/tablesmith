# frozen_string_literal: true

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

  it 'just works with print' do
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | 1 | 2 | 3 |
      +---+---+---+
    TABLE

    begin
      orig_stdout = $stdout
      sio = StringIO.new
      $stdout = sio
      print({a: 1, b: 2, c: 3}.to_table)
      sio.string.should == expected
    ensure
      $stdout = orig_stdout
    end
  end
end
