module Tablesmith::ArrayRowsSource
  def text_table
    build_columns if columns.nil?
    super
  end

  def convert_item_to_hash_row(item)
    item
  end

  # def flatten_hash_to_row(deep_hash, columns)
  #   row = ActiveSupport::OrderedHash.new
  #   columns.each do |col_or_hash|
  #     value_from_hash(row, deep_hash, col_or_hash)
  #   end
  #   row
  # end

  # TODO: no support for deep
  def build_columns
    @columns ||= []
    self.map do |array_row|
      @columns << array_row.map { |item| Tablesmith::Column.new(name: item) }
    end
    @columns.flatten!
  end

  def create_headers(rows)
    column_names = rows.shift
    grouped_headers(column_names) + [apply_column_aliases(column_names), :separator]
  end

  # def value_from_hash(row, deep_hash, col_or_hash)
  #   case col_or_hash
  #     when Tablesmith::Column
  #       row[col_or_hash.display_name] = deep_hash[col_or_hash.name]
  #     when Hash
  #       col_or_hash.each_pair do |sub_hash_key, cols_or_hash|
  #         [cols_or_hash].flatten.each do |inner_col_or_hash|
  #           value_from_hash(row, deep_hash[sub_hash_key], inner_col_or_hash)
  #         end
  #       end
  #     else
  #       nil
  #   end
  # rescue => e
  #   $stderr.puts "#{e.message}: #{col_or_hash}" if @debug
  # end

  # def hash_rows_to_text_table(hash_rows)
  #   require 'text-table'
  #
  #   header_row = hash_rows.first.keys
  #   table = []
  #   table << header_row
  #
  #   hash_rows.each do |hash_row|
  #     row = []
  #     header_row.each do |header|
  #       row << hash_row[header]
  #     end
  #     table << row
  #   end
  #
  #   # Array addition from text-table
  #   table.to_table(:first_row_is_head => true)
  # end
end
