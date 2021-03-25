# branca-cr

[branca](https://github.com/tuupola/branca-spec) implemention for crystal-lang(https://crystal-lang.org).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     branca:
       gitlab: eniehack/branca-cr
   ```

2. Run `shards install`

## Usage

### encode tokens

```crystal
require "branca"

config = Branca::Configuration.new
branca = Branca::Token.new
token = branca.encode "Hello world!".to_slice, config
```

### decode tokens

```crystal
require "branca"

config = Branca::Configuration.new
branca = Branca::Token.new
token = branca.decode "870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z", config
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://gitlab.com/eniehack/branca-cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [eniehack](https://gitlab.com/eniehack) - creator and maintainer
