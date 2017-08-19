module Tablesmith::ActiveRecordSource
  include Tablesmith::HashRowsBase

  def convert_item_to_hash_row(item)
    # TODO: reload ActiveRecords automagically
    if item.respond_to? :serializable_hash
      hash = item.serializable_hash(process_all_columns(serializable_options))
      hash = fold_un_sourced_attributes_into_source_hash(first.class.name.underscore.to_sym, hash)
      flatten_inner_hashes(hash)
    else
      super
    end
  end

  def column_order
    @columns.map(&:full_unaliased_name)
  end

  # allows overriding
  def serializable_options
    {}
  end

  def process_all_columns(serializable_options)
    build_columns(serializable_options)

    serializable_options
  end

  def build_columns(serializable_options)
    @columns || begin
      @columns = []

      process_columns(serializable_options, first.class)

      include = serializable_options[:include]

      # swiped from activemodel-3.2.17/lib/active_model/serialization.rb
      unless include.is_a?(Hash)
        include = Hash[Array.wrap(include).map { |n| n.is_a?(Hash) ? n.to_a.first : [n, {}] }]
      end

      include.each do |association, opts|
        ar_class = first.class.reflections[association].klass
        process_columns(opts, ar_class)
      end
    end
  end

  def process_columns(serializable_options, ar_class)
    only = serializable_options[:only]
    ar_columns = ar_class.columns.map { |c| Tablesmith::Column.new(name: c.name.to_s, source: ar_class.name.underscore) }
    @columns += ar_columns
    de_alias_columns(only, ar_columns) if only
    @columns += (serializable_options[:methods] || []).map do |meth_sym|
      Tablesmith::Column.new(name: meth_sym.to_s, source: ar_class.name.underscore)
    end
  end

  def de_alias_columns(only, ar_columns)
    only.map! do |attr|
      hits = ar_columns.select { |c| c.name =~ /#{attr.to_s.gsub(/_/, '.*')}/ }
      if hits.present?
        hit = hits[0] # TODO: support multiple hits
        if attr != hit
          hit.alias = attr
          hit.name
        else
          attr
        end
      else
        attr
      end
    end
  end

  def flatten_inner_hashes(hash)
    new_hash = {}
    stack = hash.each_pair.to_a
    while ary = stack.shift
      key, value = ary
      if value.is_a?(Hash)
        value.each_pair do |assoc_key, assoc_value|
          new_hash["#{key}.#{assoc_key}"] = assoc_value.to_s
        end
      else
        new_hash[key] = value
      end
    end
    new_hash
  end

  # Top-level attributes aren't nested in their own hash by default, this
  # normalizes the overall hash by grouping those together:
  #
  # converts {"name"=>"supplier",               "account"=>{"name"=>'account'}}
  #     into {"supplier"=>{"name"=>'supplier'}, "account"=>{"name"=>'account'}}
  def fold_un_sourced_attributes_into_source_hash(source_sym, hash)
    new_hash = {}
    new_hash[source_sym] = hash
    hash.delete_if { |k, v| new_hash[k] = v if v.is_a?(Hash) }
    new_hash
  end
end
