[![Gem Version](https://badge.fury.io/rb/toonrb.svg)](https://badge.fury.io/rb/toonrb)
[![Regression](https://github.com/taichi-ishitani/toonrb/actions/workflows/regression.yml/badge.svg)](https://github.com/taichi-ishitani/toonrb/actions/workflows/regression.yml)
[![codecov](https://codecov.io/gh/taichi-ishitani/toonrb/graph/badge.svg?token=kT9yJlJCuD)](https://codecov.io/gh/taichi-ishitani/toonrb)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A231E3I)

# Toonrb

[Toon](https://toonformat.dev) is a structural text format optimized for LLM input.
Toonrb is a Racc-based decoder gem that decodes Toon input into Ruby objects.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add toonrb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install toonrb
```

## Usage

You can use the methods below to decode Toon into Ruby objects.

* Decode the given Toon string
    * `Toonrb.decode`
* Decode the Toon string read from the given file path
    * `Toonrb.decode_file`

All hash keys are symbolized when the `symbolize_names` option is set to `true`.

```ruby
require 'toonrb'

toon = Toonrb.decode(<<~'TOON', symbolize_names: true)
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

The `Toonrb::ParseError` exception is raised if the given Toon includes errors listed in [here](https://github.com/toon-format/spec/blob/main/SPEC.md#14-strict-mode-errors-and-diagnostics-authoritative-checklist).

```ruby
begin
  Toonrb.decode(<<~'TOON')
    freends[4]: ana,Luis,sam
  TOON
rescue Toonrb::ParseError => e
  puts e
end

# output
# expected 4 array items, but got 3 -- filename: unknown line: 1 column: 8
```

For more details about APIs, please visit the [documentation page](https://taichi-ishitani.github.io/toonrb/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taichi-ishitani/toonrb.

* [Issue Tracker](https://github.com/taichi-ishitani/toonrb/issues)
* [Pull Request](https://github.com/taichi-ishitani/toonrb/pulls)
* [Discussion](https://github.com/taichi-ishitani/toonrb/discussions)

## License

Copyright &copy; 2025 Taichi Ishitani.
Toonrb is licensed under the terms of the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE.txt](LICENSE.txt) for further details.
