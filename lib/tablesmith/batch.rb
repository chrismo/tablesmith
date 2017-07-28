require 'text-table'

module Tablesmith
  class Batch < Array
    def method_missing(meth_id, *args)
      count = 1
      self.map do |t|
        $stderr.print '.' if count.divmod(100)[1] == 0
        count += 1
        t.send(meth_id, *args)
      end
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

      rows.map! do |row|
        # this sort gives preference to column_order then falls back to alphabetic for leftovers.
        # this is handy when columns auto-generate based on hash data.
        row.sort do |a, b|
          a_col_name, b_col_name = [a.first, b.first]
          a_col_index, b_col_index = [column_order.index(a_col_name), column_order.index(b_col_name)]

          if a_col_index.nil? && b_col_index.nil?
            a_col_name <=> b_col_name
          else
            (a_col_index || 999) <=> (b_col_index || 999)
          end
        end
      end

      rows = create_headers(rows) + (rows.map { |r| r.map(&:last) })
      rows.to_text_table
    end

    # override in subclass or mixin
    def convert_item_to_hash_row(item)
      item
    end

    # override in subclass or mixin
    def column_order
      []
    end


    # TODO: resolve with column_order
    def columns
      @columns
    end

    def create_headers(rows)
      column_names = rows.first.map(&:first)
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

    # not all resulting rows will have data in all columns, so make sure all rows pad out missing columns
    def normalize_keys(rows)
      all_keys = rows.map { |hash_row| hash_row.keys }.flatten.uniq
      rows.map { |hash_row| all_keys.each { |key| hash_row[key] ||= '' } }
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
  end
end

class Array
  def to_batch
    b = Tablesmith::Batch.new(self)

    if b.first && b.first.is_a?(ActiveRecord::Base)
      b.extend Tablesmith::ActiveRecordSource
    end

    if b.first && b.first.is_a?(Hash)
      b.extend Tablesmith::HashRowsSource
    end

    b
  end
end

