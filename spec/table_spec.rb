# frozen_string_literal: true

require 'spec_helper'

include Tablesmith # rubocop:disable Style/MixinUsage:

describe Table do
  it 'should delegate to the internal array' do
    b = Table.new
    b.length.should == 0
    b << 1
    b << 'a'
    b[0].should == 1
    b[1].should == 'a'
    b.class.should == Table
  end

  it 'should no longer pass unmatched Array messages to all items' do

    # earlier pre-1.0 versions implemented method_missing in order to provide
    # syntactic sugar for calling map on the underlying Array. But as time went
    # on, it felt too heavy-handed and not worth it.

    b = Table.new
    b.length.should == 0
    b << 1
    b << '2'
    b.map(&:to_i).should == [1, 2]
    -> { b.to_i }.should raise_error(NoMethodError)
  end

  it 'should handle empty Array' do
    expected = <<~TEXT
      +---------+
      | (empty) |
      +---------+
    TEXT
    [].to_table.to_s.should == expected
  end

  it 'should handle a simple two row Array' do
    a = [%w[a b c], %w[d e f]]
    actual = a
    expected = <<~TABLE
      +---+---+---+
      | a | b | c |
      +---+---+---+
      | d | e | f |
      +---+---+---+
    TABLE
    actual.to_table.to_s.should == expected
  end

  it 'should output csv' do
    a = [['a', 'b,s', 'c'], %w[d e f]]
    actual = a
    expected = <<~TABLE
      a,"b,s",c
      d,e,f
    TABLE
    actual.to_table.to_csv.should == expected
  end

  it 'should output html' do
    actual = [%w[a b c], %w[d e f], %w[g h i]]
    expected = <<~TABLE
      <table>
          <thead>
          <tr>
              <th>a</th>
              <th>b</th>
              <th>c</th>
          </tr>
          </thead>
          <tbody>
          <tr>
              <td>d</td>
              <td>e</td>
              <td>f</td>
          </tr>
          <tr>
              <td>g</td>
              <td>h</td>
              <td>i</td>
          </tr>
          </tbody>
      </table>
    TABLE
    actual.to_table.to_html.should == expected
  end
end
