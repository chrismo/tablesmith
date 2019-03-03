# frozen_string_literal: true

class HtmlFormatter
  attr_reader :indent

  def initialize(table)
    @table = table
    @indent = '    '
  end

  def to_html
    @lines = []
    @lines << '<table>'
    append_table_head
    append_table_body
    @lines << '</table>'
    @lines.join("\n") + "\n"
  end

  private

  def append_table_head
    @lines << "#{indent}<thead>"
    unless @table.empty?
      rows = @table.text_table.rows[0..0]
      append_rows(rows, 'th')
    end
    @lines << "#{indent}</thead>"
  end

  def append_table_body
    @lines << "#{indent}<tbody>"
    unless @table.empty?
      rows = @table.text_table.rows[2..-1]
      append_rows(rows, 'td')
    end
    @lines << "#{indent}</tbody>"
  end

  def append_rows(rows, tag)
    rows.each do |row|
      next if row == :separator

      @lines << "#{indent}<tr>"
      row.map do |cell|
        value = cell_value(cell)
        @lines << "#{indent}#{indent}<#{tag}>#{value}</#{tag}>"
      end
      @lines << "#{indent}</tr>"
    end
  end

  def cell_value(cell)
    case cell
    when Hash
      cell[:value]
    else
      cell
    end
  end
end
