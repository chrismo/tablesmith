# frozen_string_literal: true

require 'spec_helper'

describe 'HashRowsSource' do
  it 'outputs text table of simple hash row with default columns' do
    expected = <<~TABLE
      +---+---+
      | a | b |
      +---+---+
      | 1 | 2 |
      +---+---+
    TABLE
    [{ a: 1, b: 2 }].to_table.to_s.should == expected
  end

  it 'outputs text table of hash row with nested Array' do
    expected = <<~TABLE
      +---+--------+
      | a |   b    |
      +---+--------+
      | 1 | [1, 2] |
      +---+--------+
    TABLE
    [{ a: 1, b: [1, 2] }].to_table.to_s.should == expected
  end

  it 'outputs text table of hash row with nested Hash' do
    expected = <<~TABLE
      +---+---------+
      | a |    b    |
      +---+---------+
      | 1 | {:c=>3} |
      +---+---------+
    TABLE
    [{ a: 1, b: { c: 3 } }].to_table.to_s.should == expected
  end

  it 'outputs text table of mixed columns hash rows with default columns' do
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | 1 | 2 |   |
      | 2 |   | ! |
      +---+---+---+
    TABLE
    [
      { a: 1, b: 2 },
      { a: 2, c: '!' }
    ].to_table.to_s.should == expected
  end

  it 'outputs text table of deep hash rows with defined columns' do
    pending

    expected = <<~TABLE
      +---+---+---+
      | a |   b   |
      +---+---+---+
      |   | c | d |
      +---+---+---+
      | 1 | 2 | 2 |
      +---+---+---+
    TABLE
    b = [{ a: 1, b: { c: 2, d: 2 } }].to_table
    # def b.columns
    #   [
    #     Column.new(name: :a),
    #     { b: [
    #       Column.new(name: :c)
    #     ] }
    #   ]
    # end

    # this would be nice.
    # should be able to re-use what happens with ActiveRecord
    b.to_s.should == expected
  end

  it 'keeps OrderedHash keys in order' do
    h = ActiveSupport::OrderedHash.new
    h[:z] = 2
    h[:y] = 1
    expected = <<~TABLE
      +---+---+
      | z | y |
      +---+---+
      | 2 | 1 |
      +---+---+
    TABLE
    h.to_table.to_s.should == expected
  end

  it 'outputs text table of deep hash rows with default columns'
end
