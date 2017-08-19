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
    [{a: 1, b: 2}].to_table.text_table.to_s.should == expected
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
      {a: 1, b: 2},
      {a: 2, c: '!'}
    ].to_table.text_table.to_s.should == expected
  end

  it 'outputs text table of deep hash rows with defined columns' do
    expected = <<~TABLE
      +---+---+---+
      |   |   b   |
      +---+---+---+
      | a | c | d |
      +---+---+---+
      | 1 | 2 | 2 |
      +---+---+---+
    TABLE
    b = [{a: 1, b: {c: 2, d: 2}}].to_table
    def b.columns
      [
        Column.new(name: :a),
        {b: [
          Column.new(name: :c)
        ]}
      ]
    end
    # this would be nice. Payments has some code along these lines for BraintreeBatch? or some ActiveRecordSource re-use?
    # b.text_table.to_s.should == expected
    pending
  end

  it 'outputs text table of deep hash rows with default columns'
end
