module Tablesmith::HashRowsSource
  def text_table
    build_columns if columns.nil?
    super
  end

  def convert_item_to_hash_row(item)
    flatten_hash_to_row(item, columns)
  end

  def flatten_hash_to_row(deep_hash, columns)
    row = ActiveSupport::OrderedHash.new
    columns.each do |col_or_hash|
      value_from_hash(row, deep_hash, col_or_hash)
    end
    row
  end

  # TODO: no support for deep
  def build_columns
    @columns ||= []
    self.map do |hash_row|
      @columns << hash_row.keys.map { |k| Tablesmith::Column.new(name: k) }
    end 
    @columns.flatten!
  end

  def value_from_hash(row, deep_hash, col_or_hash)
    case col_or_hash
    when Tablesmith::Column
      row[col_or_hash.display_name] = deep_hash[col_or_hash.name]
    when Hash
      col_or_hash.each_pair do |sub_hash_key, cols_or_hash|
        [cols_or_hash].flatten.each do |inner_col_or_hash|
          value_from_hash(row, deep_hash[sub_hash_key], inner_col_or_hash)
        end
      end
    else
      nil
    end
  rescue => e
    $stderr.puts "#{e.message}: #{col_or_hash}" if @debug
  end

  def hash_rows_to_text_table(hash_rows)
    require 'text-table'

    header_row = hash_rows.first.keys
    table = []
    table << header_row

    hash_rows.each do |hash_row|
      row = []
      header_row.each do |header|
        row << hash_row[header]
      end
      table << row
    end

    # Array addition from text-table
    table.to_table(:first_row_is_head => true)
  end

  # not all resulting rows will have data in all columns, so make sure all rows pad out missing columns
  def normalize_keys(rows)
    all_keys = rows.map { |hash_row| hash_row.keys }.flatten.uniq
    rows.map { |hash_row| all_keys.each { |key| hash_row[key] ||= '' } }
  end

  def sort_columns(rows)
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
  end

  def row_values(row)
    row.map(&:last)
  end

  def create_headers(rows)
    column_names = rows.first.map(&:first)
    grouped_headers(column_names) + [apply_column_aliases(column_names), :separator]
  end
end
