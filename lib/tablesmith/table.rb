require 'text-table'
require 'csv'

module Tablesmith
  class Table < Array
    def method_missing(meth_id, *args)
      count = 1
      self.map do |t|
        $stderr.print '.' if count.divmod(100)[1] == 0
        count += 1
        t.send(meth_id, *args)
      end
    end

    def respond_to_missing?
      super
    end

    # irb
    def inspect
      pretty_inspect
    end

    # Pry 0.9 calls this
    def pretty_inspect
      text_table.to_s
    end

    # Pry 0.10 eventually uses PP, and this is the PP way to provide custom output
    def pretty_print(pp)
      pp.text pretty_inspect
    end

    def text_table
      return ['(empty)'].to_text_table if self.empty?

      rows = self.map { |item| convert_item_to_hash_row(item) }.compact

      normalize_keys(rows)

      sort_columns(rows)

      rows = create_headers(rows) + (rows.map { |row| row_values(row) })
      rows.to_text_table
    end

    def to_csv
      CSV.generate do |csv|
        text_table.rows.each do |row|
          next if row == :separator
          csv << row.map do |cell|
            case cell
              when Hash
                cell[:value]
              else
                cell
            end
          end
        end
      end
    end

    def to_html
      HtmlFormatter.new(self).to_html
    end

    # override in subclass or mixin
    def row_values(row)
      row
    end

    # override in subclass or mixin
    def sort_columns(rows)
    end

    # override in subclass or mixin
    def convert_item_to_hash_row(item)
      item
    end

    # override in subclass or mixin
    def normalize_keys(rows)
    end

    # override in subclass or mixin
    def column_order
      []
    end

    def columns
      @columns
    end

    def create_headers(rows)
      top_row = rows.first
      column_names = top_row.first.is_a?(Array) ? top_row.map(&:first) : top_row
      grouped_headers(column_names) + [apply_column_aliases(column_names), :separator]
    end

    def grouped_headers(column_names)
      groups = Hash.new { |h, k| h[k] = 0 }
      column_names.map! do |name|
        group, col = name.to_s.split(/\./)
        col, group = [group, ''] if col.nil?
        groups[group] += 1
        col
      end
      if groups.keys.length == 1 # TODO: add option to show group header row when only one exists
        []
      else
        row = []
        # this relies on Ruby versions where hash retains add order
        groups.each_pair do |name, span|
          row << {value: name, align: :center, colspan: span}
        end
        [row, :separator]
      end
    end

    def apply_column_aliases(column_names)
      column_names.map do |name|
        instance = columns.detect { |ca| ca.name.to_s == name.to_s }
        value = instance ? instance.display_name : name
        {:value => value, :align => :center}
      end
    end
  end

  class Column
    attr_accessor :source, :name, :alias

    def initialize(attributes={})
      @source = attributes.delete(:source)
      @name = attributes.delete(:name)
      @alias = attributes.delete(:alias)
    end

    def display_name
      "#{@alias || @name}"
    end

    def full_unaliased_name
      "#{@source ? "#{@source}." : ''}#{@name}"
    end

    def to_s
      "#{@source}.#{@name}#{' as ' + @alias if @alias}"
    end
  end
end

class Array
  def to_table
    b = Tablesmith::Table.new(self)

    # TODO: redesign such that every row is reacted to appropriately,
    # so mixed content could be supported. Maybe every cell could be
    # rendered appropriately, with nested tables.
    if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
      if b.first && b.first.is_a?(ActiveRecord::Base)
        b.extend Tablesmith::ActiveRecordSource
      end
    end

    if b.first && b.first.is_a?(Hash)
      b.extend Tablesmith::HashRowsSource
    end

    if b.first && b.first.is_a?(Array)
      b.extend Tablesmith::ArrayRowsSource
    end

    b
  end
end

class Hash
  def to_table
    b = Tablesmith::Table.new([self])
    b.extend Tablesmith::HashRowsSource
  end
end