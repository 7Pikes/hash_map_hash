## hash_map_hash

The `hash_map_hash` is a parser that transforms data structures (converted to
hashes) by using other hashes as maps.

It can be uses to transform `JSON`, `XML`, or anything that can be converted
to `Hash`.

It can transform plain data structures, but specifically designed to work with
complex nested data structures.

## Installation

```
gem install hash_map_hash
```

This gem has no runtime dependencies.

## Examples

```ruby
# plain data structures
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

```ruby
# nested data structures
data = { 'Contractors' =>
  { 'Contractor' =>
    [
      {
        'OfficialName' => 'FirstAid, Moscow',
        'Role' => 'Payer'
      },
      {
        'Id' => '84266',
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
  payer:    ['Contractors', 'Contractor', %w(Role Payer), 'OfficialName'],
  receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Id'],
  amount:   ['Items', 'NumberOfPositions'],
  summ:     'Total'
}

HashMapHash.new(mapping).map(data)
#{
#  payer: 'FirstAid, Moscow',
#  receiver: '84266',
#  amount: 10,
#  summ: 123.45
#}
```
