[![Gem Version](https://fury-badge.herokuapp.com/rb/hash_map_hash.png)](http://badge.fury.io/rb/hash_map_hash)
[![Build Status](https://api.travis-ci.org/7Pikes/hash_map_hash.png?branch=master)](http://travis-ci.org/7Pikes/hash_map_hash)

## hash_map_hash

The `hash_map_hash` is a parser that transforms data structures (converted to
hashes) by using other hashes as maps.

It can be used to transform `JSON`, `XML`, or anything that can be converted
to `Hash`.

With this gem, it is possible to store multiple parser configurations
(mappings) in files or in a database, and avoid writing a new parser for
every new data format.

It can transform plain data structures, but is specifically designed to work
with complex nested data structures. The resulting hash is always flat.

## Installation

```
gem install hash_map_hash
```

This gem has no runtime dependencies.

## Examples

### Plain data structures

```ruby
data = {
  'Items' => 10,
  'Total' => 123.0
}

mapping = {
  amount: 'Items',
  summ: 'Total'
}

HashMapHash.new(mapping).map(data) # { amount: 10, summ: 123.0 }
```

### Nested data structures
```ruby
data = { 'Contractors' =>
  { 'Contractor' =>
    [
      {
        'Value' => 'FirstAid, Moscow',
        'Role' => 'Payer'
      },
      {
        'Value' => '84266',
        'OfficialName' => 'FirstAid, Moscow (442, Glow st)',
        'Role' => 'Receiver'
      }
    ]
  },
  'Items' => {
    'NumberOfPositions' => 10
  },
  'Total' => 123.45
}

mapping = {
  payer:    ['Contractors', 'Contractor', %w(Role Payer), 'Value'],
  receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Value'],
  amount:   ['Items', 'NumberOfPositions'],
  summ:     'Total'
}

HashMapHash.new(mapping).map(data)
# {
#   payer: 'FirstAid, Moscow',
#   receiver: '84266',
#   amount: 10,
#   summ: 123.45
# }
```

Note about mapping: each array element represents one level of a data hash. When element itself is an array, it is used for filtering a corresponding level of input hash, which in this case is also an array.

## Nested properties

In the nested data example, two filters were applied under 'Contractors' and
'Contractor' keys. This duplication is not a big problem, even for dozens of
such filters, but you can make them more DRY if you want by using nested
properties.

```ruby
# data is the same as in the nested data example
data = { 'Contractors' =>
  { 'Contractor' =>
    [
      {
        'Value' => 'FirstAid, Moscow',
        'Role' => 'Payer'
      },
      {
        'Value' => '84266',
        'OfficialName' => 'FirstAid, Moscow (442, Glow st)',
        'Role' => 'Receiver'
      }
    ]
  },
  'Items' => {
    'NumberOfPositions' => 10
  },
  'Total' => 123.45
}

# initial maping, before adding nested properties
mapping = {
  amount:   ['Items', 'NumberOfPositions'],
  summ:     'Total'
}

nested_properties = {
  prefix: %w(Contractors Contractor),
  filter_key: 'Role',
  value_key: 'Value',
  keys: {
    payer: 'Payer',
    receiver: 'Receiver'
  }
}

mapper = HashMapHash.new(mapping)
mapper.add_nested_properties nested_properties

# Here is the new mapping.
# Now it is the same as in the nested data example.
mapper.mapping
# {
#   payer:    ['Contractors', 'Contractor', %w(Role Payer), 'Value'],
#   receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Value'],
#   amount:   ['Items', 'NumberOfPositions'],
#   summ:     'Total'
# }

# Same result as in the nested data example
mapper.map data
# {
#   payer: 'FirstAid, Moscow',
#   receiver: '84266',
#   amount: 10,
#   summ: 123.45
# }
```

# Backward transformation

For backward transformation use [hash_template](https://github.com/denispeplin/hash_template) gem.

## License

MIT.
