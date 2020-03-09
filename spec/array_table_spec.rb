# frozen_string_literal: true

require 'spec_helper'

describe 'Array Source' do
  it 'just works in a console' do
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | d | e | f |
      +---+---+---+
    TABLE
    [%w[a b c], %w[d e f]].to_table.text_table.to_s.should == expected
  end

  it 'just works with print' do
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | d | e | f |
      +---+---+---+
    TABLE

    begin
      orig_stdout = $stdout
      sio = StringIO.new
      $stdout = sio
      print [%w[a b c], %w[d e f]].to_table
      sio.string.should == expected
    ensure
      $stdout = orig_stdout
    end
  end

  it 'just works with puts' do
    pending

    # Kernel.puts has special behavior for puts with Array,
    # which Table subclasses, so this isn't going to work,
    # unless we can stop subclassing Array.
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | d | e | f |
      +---+---+---+
    TABLE

    begin
      orig_stdout = $stdout
      sio = StringIO.new
      $stdout = sio
      puts [%w[a b c], %w[d e f]].to_table
      sio.string.should == expected
    ensure
      $stdout = orig_stdout
    end
  end
end
