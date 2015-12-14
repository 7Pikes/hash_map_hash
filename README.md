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
