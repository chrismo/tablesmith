# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Rails/SkipsModelValidations
describe 'ActiveRecordSource' do
  it 'outputs text table of multiple ActiveRecords' do
    a = Person.new.tap { |c| c.first_name = 'A' }
    b = Person.new.tap { |c| c.first_name = 'B' }
    expected = <<~TABLE
      +----+------------+-----------+-----+-------------------+
      | id | first_name | last_name | age | custom_attributes |
      +----+------------+-----------+-----+-------------------+
      |    | A          |           |     |                   |
      |    | B          |           |     |                   |
      +----+------------+-----------+-----+-------------------+
    TABLE
    [a, b].to_table.to_s.should == expected
  end

  it 'outputs ActiveRecord in column order' do
    p = Person.create(first_name: 'chris', last_name: 'mo', age: 43)
    expected = <<~TABLE
      +----+------------+-----------+-----+-------------------+
      | id | first_name | last_name | age | custom_attributes |
      +----+------------+-----------+-----+-------------------+
      | 1  | chris      | mo        | 43  |                   |
      +----+------------+-----------+-----+-------------------+
    TABLE
    [p].to_table.to_s.should == expected
  end

  it 'handles custom serialization options in batch' do
    p = Person.create(first_name: 'chrismo', age: 43)

    expected = <<~TABLE
      +------------+-----+-----------+
      | first_name | age | year_born |
      +------------+-----+-----------+
      | chrismo    | 43  | 1971      |
      +------------+-----+-----------+
    TABLE
    b = [p].to_table

    def b.serializable_options
      { only: %i[first_name age], methods: [:year_born] }
    end

    b.to_s.should == expected
  end

  it 'auto reloads records' do
    p = Person.create(first_name: 'chrismo', age: 43)

    expected = <<~TABLE
      +------------+-----+-----------+
      | first_name | age | year_born |
      +------------+-----+-----------+
      | chrismo    | 43  | 1971      |
      +------------+-----+-----------+
    TABLE
    b = [p].to_table

    def b.serializable_options
      { only: %i[first_name age], methods: [:year_born] }
    end
    b.to_s.should == expected

    # update the value through another instance.
    Person.last.update_column(:age, 46)

    expected = <<~TABLE
      +------------+-----+-----------+
      | first_name | age | year_born |
      +------------+-----+-----------+
      | chrismo    | 46  | 1968      |
      +------------+-----+-----------+
    TABLE
    b.to_s.should == expected
  end

  it 'handles column name partials' do
    p = Person.create(first_name: 'chris', last_name: 'mo', age: 43)
    expected = <<~TABLE
      +-------+------+-----+
      | first | last | age |
      +-------+------+-----+
      | chris | mo   | 43  |
      +-------+------+-----+
    TABLE
    b = [p].to_table

    def b.serializable_options
      { only: %i[first last age] }
    end

    b.to_s.should == expected
  end

  it 'handles column name partials across words' do
    p = Person.create(first_name: 'chris', last_name: 'mo', age: 43)
    expected = <<~TABLE
      +--------+--------+-----+
      | f_name | l_name | age |
      +--------+--------+-----+
      | chris  | mo     | 43  |
      +--------+--------+-----+
    TABLE
    b = [p].to_table

    def b.serializable_options
      { only: %i[f_name l_name age] }
    end

    b.to_s.should == expected
  end

  it 'handles explicit column aliases' do
    p = Person.create(first_name: 'chris', last_name: 'mo', age: 43)
    expected = <<~TABLE
      +---------------+----------+-----+
      | primer_nombre | apellido | age |
      +---------------+----------+-----+
      | chris         | mo       | 43  |
      +---------------+----------+-----+
    TABLE
    b = [p].to_table

    def b.columns
      [Tablesmith::Column.new(name: :first_name, alias: :primer_nombre),
       Tablesmith::Column.new(name: :last_name, alias: :apellido)]
    end

    def b.serializable_options
      { only: %i[first_name last_name age] }
    end

    b.to_s.should == expected
  end

  it 'handles associations without aliases' do
    s = Supplier.create(name: 'supplier')
    s.account = Account.create(name: 'account', tax_identification_number: '123456')
    b = [s].to_table

    def b.serializable_options
      { only: [:name], include: { account: { only: %i[name tax_identification_number] } } }
    end

    expected = <<~TABLE
      +----------+---------+---------------------------+
      | supplier |               account               |
      +----------+---------+---------------------------+
      |   name   |  name   | tax_identification_number |
      +----------+---------+---------------------------+
      | supplier | account | 123456                    |
      +----------+---------+---------------------------+
    TABLE

    b.to_s.should == expected
  end

  it 'handles associations with aliases' do
    s = Supplier.create(name: 'supplier')
    s.account = Account.create(name: 'account', tax_identification_number: '123456')
    b = [s].to_table

    def b.serializable_options
      { only: [:name], include: { account: { only: %i[name tax_id] } } }
    end

    expected = <<~TABLE
      +----------+---------+--------+
      | supplier |     account      |
      +----------+---------+--------+
      |   name   |  name   | tax_id |
      +----------+---------+--------+
      | supplier | account | 123456 |
      +----------+---------+--------+
    TABLE

    b.to_s.should == expected
  end

  it 'retains serializable_options ordering'

  it 'supports multiple associations'

  it 'supports nested associations'

  # may need/want to handle the hash resulting from an association differently from the hash resulting from a method/attr
  it 'supports field with hash contents' do
    p = Person.create(first_name: 'chrismo', custom_attributes: { skills: { instrument: 'piano', style: 'jazz' } })
    b = [p].to_table

    a = format_ids([p.id])[0]
    expected = <<~TABLE
      +----+------------+-----------+-----+----------------------------------------+
      |              person               |           custom_attributes            |
      +----+------------+-----------+-----+----------------------------------------+
      | id | first_name | last_name | age |                 skills                 |
      +----+------------+-----------+-----+----------------------------------------+
      |#{a}| chrismo    |           |     | {:instrument=>"piano", :style=>"jazz"} |
      +----+------------+-----------+-----+----------------------------------------+
    TABLE

    b.to_s.should == expected
  end

  it 'supports multiple rows with different column counts' do
    p2 = Person.create(first_name: 'romer', custom_attributes: { instrument: 'kazoo' })
    p1 = Person.create(first_name: 'chrismo', custom_attributes: { instrument: 'piano', style: 'jazz' })
    p3 = Person.create(first_name: 'glv', custom_attributes: {})
    batch = [p2, p1, p3].to_table

    a, b, c = format_ids([p2.id, p1.id, p3.id])

    expected = <<~TABLE
      +----+------------+-----------+-----+------------+-----------+
      |              person               |   custom_attributes    |
      +----+------------+-----------+-----+------------+-----------+
      | id | first_name | last_name | age | instrument |   style   |
      +----+------------+-----------+-----+------------+-----------+
      |#{a}| romer      |           |     | kazoo      |           |
      |#{b}| chrismo    |           |     | piano      | jazz      |
      |#{c}| glv        |           |     |            |           |
      +----+------------+-----------+-----+------------+-----------+
    TABLE

    batch.to_s.should == expected
  end

  it 'supports consistent ordering of dynamic columns' do
    p1 = Person.create(first_name: 'chrismo', custom_attributes: { instrument: 'piano', style: 'jazz' })
    p2 = Person.create(first_name: 'romer', custom_attributes: { hobby: 'games' })
    batch = [p1, p2].to_table

    a, b = format_ids([p1.id, p2.id])

    expected = <<~TABLE
      +----+------------+-----------+-----+--------+------------+--------+
      |              person               |      custom_attributes       |
      +----+------------+-----------+-----+--------+------------+--------+
      | id | first_name | last_name | age | hobby  | instrument | style  |
      +----+------------+-----------+-----+--------+------------+--------+
      |#{a}| chrismo    |           |     |        | piano      | jazz   |
      |#{b}| romer      |           |     | games  |            |        |
      +----+------------+-----------+-----+--------+------------+--------+
    TABLE

    batch.to_s.should == expected
  end

  it 'handles AR instance without an association present' do
    s = Supplier.create(name: 'supplier')
    b = [s].to_table

    def b.serializable_options
      { only: [:name], include: { account: { only: %i[name tax_id] } } }
    end

    expected = <<~TABLE
      +----------+
      |   name   |
      +----------+
      | supplier |
      +----------+
    TABLE

    b.to_s.should == expected
  end

  it 'properly groups when original columns not sequential' do
    s2 = Supplier.create(name: 'sup. two', custom_attributes: { a: 1 })

    def s2.foo
      ''
    end

    b = [s2].to_table

    # methods need Columns as well
    def b.serializable_options
      { only: %i[name custom_attributes], methods: [:foo] }
    end

    expected = <<~TABLE
      +----------+------+-------------------+
      |    supplier     | custom_attributes |
      +----------+------+-------------------+
      |   name   | foo  |         a         |
      +----------+------+-------------------+
      | sup. two |      | 1                 |
      +----------+------+-------------------+
    TABLE

    b.to_s.should == expected
  end

  it 'supports one to many association' do
    p = Parent.create(name: 'parent')
    Child.create(name: 'child', parent: p)

    b = [p].to_table

    # little weird looking at this point, but at least not broken
    expected = <<~TABLE
      +----+--------+-------------------+---------------------+
      | id |  name  | custom_attributes |      children       |
      +----+--------+-------------------+---------------------+
      | 1  | parent |                   | [{"name"=>"child"}] |
      +----+--------+-------------------+---------------------+
    TABLE

    def b.serializable_options
      { include: { children: { only: [:name] } } }
    end

    b.to_s.should == expected
  end

  def format_ids(ary)
    ary.map { |value| " #{value.to_s.ljust(3)}" }
  end

  describe 'fold un-sourced attributes into source hash' do
    let(:obj) { Object.new.extend Tablesmith::ActiveRecordSource }

    it 'should handle simple hash' do
      obj.fold_un_sourced_attributes_into_source_hash(:foo, a: 1, b: 2).should == { foo: { a: 1, b: 2 } }
    end

    it 'should handle nested hashes' do
      before = { 'name' => 'chris', account: { 'name' => 'account_name' } }
      expected = { foo: { 'name' => 'chris' }, account: { 'name' => 'account_name' } }
      obj.fold_un_sourced_attributes_into_source_hash(:foo, before).should == expected
    end

    it 'should handle deep nested hashes' do
      before = { 'name' => 'chris', account: { 'id' => { 'name' => 'account_name', 'number' => 123_456 } } }
      expected = { foo: { 'name' => 'chris' }, account: { 'id' => { 'name' => 'account_name', 'number' => 123_456 } } }
      obj.fold_un_sourced_attributes_into_source_hash(:foo, before).should == expected
    end
  end

  describe 'flatten_inner_hashes' do
    let(:obj) { Object.new.extend Tablesmith::ActiveRecordSource }

    it 'should flatten inner hash' do
      before = { foo: { 'name' => 'chris' }, account: { 'name' => 'account_name' } }
      expected = { 'foo.name' => 'chris', 'account.name' => 'account_name' }

      obj.flatten_inner_hashes(before).should == expected
    end

    it 'should to_s deep nested hashes' do
      before = { foo: { 'name' => 'chris' }, account: { 'id' => { 'name' => 'account_name', 'number' => 123_456 } } }
      expected = { 'foo.name' => 'chris', 'account.id' => '{"name"=>"account_name", "number"=>123456}' }

      obj.flatten_inner_hashes(before).should == expected
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
