# branca-cr

[![Docs status](https://img.shields.io/badge/docs-available-brightgreen.svg?style=flat-square)](https://eniehack.gitlab.io/branca.cr/)
![Gitlab pipeline status](https://img.shields.io/gitlab/pipeline/eniehack/branca.cr/master?style=flat-square)

[branca](https://github.com/tuupola/branca-spec) implemention for crystal-lang(https://crystal-lang.org).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     branca:
       gitlab: eniehack/branca.cr
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

## License

copyright (c) 2021 eniehack

This software is licensed under [Apache License 2.0](https://apache.org/licenses/LICENSE-2.0.txt).

but, `./spec/test_vectors.json`is provided from https://github.com/tuupola/branca-spec/blob/527997e1c954d450a503b12099652bbdf7fdb168/test_vectors.json , licensed by MIT/X11 License.
so, this file is owned copyright by [tuupola](https://github.com/tuupola).

## Contributing

1. Fork it (<https://gitlab.com/eniehack/branca-cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [eniehack](https://gitlab.com/eniehack) - creator and maintainer
