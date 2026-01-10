[![Gem Version](https://badge.fury.io/rb/rbtoon.svg)](https://badge.fury.io/rb/rbtoon)
[![Regression](https://github.com/taichi-ishitani/rbtoon/actions/workflows/regression.yml/badge.svg)](https://github.com/taichi-ishitani/rbtoon/actions/workflows/regression.yml)
[![codecov](https://codecov.io/gh/taichi-ishitani/rbtoon/graph/badge.svg?token=P35M7RTL3W)](https://codecov.io/gh/taichi-ishitani/rbtoon)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A231E3I)

# RbToon

[Toon](https://toonformat.dev) is a structural text format optimized for LLM input.
RbToon is a Racc-based decoder gem that decodes Toon input into Ruby objects.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add rbtoon
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rbtoon
```

## Usage

You can use the methods below to decode Toon into Ruby objects.

* Decode the given Toon string
    * `RbToon.decode`
* Decode the Toon string read from the given file path
    * `RbToon.decode_file`

All hash keys are symbolized when the `symbolize_names` option is set to `true`.

```ruby
require 'rbtoon'

toon = RbToon.decode(<<~'TOON', symbolize_names: true)
  context:
    task: Our favorite hikes together
    location: Boulder
    season: spring_2025
  friends[3]: ana,luis,sam
  hikes[3]{id,name,distanceKm,elevationGain,companion,wasSunny}:
    1,Blue Lake Trail,7.5,320,ana,true
    2,Ridge Overlook,9.2,540,luis,false
    3,Wildflower Loop,5.1,180,sam,true
TOON

# output
# {context: {task: "Our favorite hikes together", location: "Boulder", season: "spring_2025"},
#  friends: ["ana", "luis", "sam"],
#  hikes:
#   [{id: 1, name: "Blue Lake Trail", distanceKm: 7.5, elevationGain: 320, companion: "ana", wasSunny: true},
#    {id: 2, name: "Ridge Overlook", distanceKm: 9.2, elevationGain: 540, companion: "luis", wasSunny: false},
#    {id: 3, name: "Wildflower Loop", distanceKm: 5.1, elevationGain: 180, companion: "sam", wasSunny: true}]}
```

The `RbToon::ParseError` exception is raised if the given Toon includes errors listed in [here](https://github.com/toon-format/spec/blob/main/SPEC.md#14-strict-mode-errors-and-diagnostics-authoritative-checklist).

```ruby
begin
  RbToon.decode(<<~'TOON')
    freends[4]: ana,Luis,sam
  TOON
rescue RbToon::ParseError => e
  puts e
end

# output
# expected 4 array items, but got 3 -- filename: unknown line: 1 column: 8
```

For more details about APIs, please visit the [documentation page](https://taichi-ishitani.github.io/rbtoon/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taichi-ishitani/rbtoon.

* [Issue Tracker](https://github.com/taichi-ishitani/rbtoon/issues)
* [Pull Request](https://github.com/taichi-ishitani/rbtoon/pulls)
* [Discussion](https://github.com/taichi-ishitani/rbtoon/discussions)

## License

Copyright &copy; 2025 Taichi Ishitani.
RbToon is licensed under the terms of the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE.txt](LICENSE.txt) for further details.
