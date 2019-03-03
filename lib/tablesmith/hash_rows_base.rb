# frozen_string_literal: true

# ActiveRecord and HashRowsSource share a lot, but not everything.
module Tablesmith::HashRowsBase
  # not all resulting rows will have data in all columns, so make sure all rows pad out missing columns
  def normalize_keys(rows)
    all_keys = rows.map(&:keys).flatten.uniq
    rows.map { |hash_row| all_keys.each { |key| hash_row[key] ||= '' } }
  end

  def sort_columns(rows)
    return if column_order.empty?

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
