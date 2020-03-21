[![Build Status](https://travis-ci.org/livingsocial/tablesmith.svg?branch=master)](https://travis-ci.org/livingsocial/tablesmith)

# Tablesmith

Drop-in gem for console tables for Array, Hash, and ActiveRecord.

## Installation

Add this line to your application's Gemfile:

    gem 'tablesmith'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tablesmith

## Usage

### In irb or pry

```
require 'tablesmith'
           
> [[:foo, :bar], [1,3]].to_table                                                                                                                                                                                         
=> +-----+-----+
| foo | bar |
+-----+-----+
| 1   | 3   |
+-----+-----+

> {a: 1, b: 2}.to_table
=> +---+---+
| a | b |
+---+---+
| 1 | 2 |
+---+---+
   
> t = [{date: '1/1/2020', amt: 35}, {date: '1/2/2020', amt: 80}].to_table
=> +----------+-----+
|   date   | amt |
+----------+-----+
| 1/1/2020 | 35  |
| 1/2/2020 | 80  |
+----------+-----+
                                    
> # Table delegates to Array, all Array methods are available.
> t.select! { |h| h[:amt] > 40 }    
=> [{:date=>"1/2/2020", :amt=>80}]

> t
=> +----------+-----+
|   date   | amt |
+----------+-----+
| 1/2/2020 | 80  |
+----------+-----+

           
> p1 = Person.create(first_name: 'chrismo', custom_attributes: { instrument: 'piano', style: 'jazz' })    
=> #<Person:0x00007fac3eb406a8 id: 1, first_name: "chrismo", last_name: nil, age: nil, custom_attributes: {:instrument=>"piano", :style=>"jazz"}>
> p2 = Person.create(first_name: 'romer', custom_attributes: { hobby: 'games' })    
=> #<Person:0x00007fac3ebcbb68 id: 2, first_name: "romer", last_name: nil, age: nil, custom_attributes: {:hobby=>"games"}>
> batch = [p1, p2].to_table    
=> +----+------------+-----------+-----+--------+------------+--------+
|              person               |      custom_attributes       |
+----+------------+-----------+-----+--------+------------+--------+
| id | first_name | last_name | age | hobby  | instrument | style  |
+----+------------+-----------+-----+--------+------------+--------+
| 1  | chrismo    |           |     |        | piano      | jazz   |
| 2  | romer      |           |     | games  |            |        |
+----+------------+-----------+-----+--------+------------+--------+
```

### In a Script

`puts` won't work because of how Kernel#puts has special case code for Arrays.
Tablesmith::Table subclasses Array, so it can't cope with puts. Try to remember
to use `print` instead.

```ruby
require 'tablesmith'

print [{date: '1/1/2020', amt: 35}, {date: '1/2/2020', amt: 80}].to_table 
```

### CSV Support
``` 
> puts [{date: '1/1/2020', amt: 35}, {date: '1/2/2020', amt: 80}].to_table.to_csv
date,amt
1/1/2020,35
1/2/2020,80
```

### HTML Support
```
> puts [{date: '1/1/2020', amt: 35}, {date: '1/2/2020', amt: 80}].to_table.to_html
<table>
    <thead>
    <tr>
        <th>date</th>
        <th>amt</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td>1/1/2020</td>
        <td>35</td>
    </tr>
    <tr>
        <td>1/2/2020</td>
        <td>80</td>
    </tr>
    </tbody>
</table>
```

## Troubleshooting

If you ever get a default inspection output in a console for a table, an
exception has likely occurred and been caught by IRB or Pry. Call
`.to_table.to_s` to see what the exception is.

```
[1] pry(main)> [1, [2, 3]].to_table
=> #<Tablesmith::Table:0x3fc083e14294>
[2] pry(main)> [1, [2, 3]].to_table.to_s
IndexError: element size differs (2 should be 1)
from /Users/chrismo/.bundle/ruby/2.6.0/gems/text-table-1.2.4/lib/text-table/table.rb:157:in `transpose'
```

## Why Not #{other_gem}?

Happy to learn about something else already out there, but I have struggled to
find something that doesn't require some sort of setup. I want drop-in
ready-to-go table output for Arrays, Hashes, and ActiveRecord objects.

Here's a quick list of other gems that I've tried out that are awesome and do
much more than what Tablesmith does, but don't seem to specialize in what I
want:

  - [text-table](https://github.com/aptinio/text-table) _Tablesmith uses text-table underneath_
  - [Hirb](https://github.com/cldwalker/hirb) _Hirb is cool, and pretty close to what I want_
  - [table_print](http://tableprintgem.com/)
  - [awesome_print](https://github.com/awesome-print/awesome_print)
  - [tabulo](https://github.com/matt-harvey/tabulo)
