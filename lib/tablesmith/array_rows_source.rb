module Tablesmith::ArrayRowsSource
  def text_table
    build_columns if columns.nil?
    super
  end

  def convert_item_to_hash_row(item)
    item
  end

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
end
