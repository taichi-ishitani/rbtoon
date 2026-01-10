# frozen_string_literal: true

require 'strscan'

require_relative 'toonrb/version'
require_relative 'toonrb/parse_error'
require_relative 'toonrb/token'
require_relative 'toonrb/nodes/base'
require_relative 'toonrb/nodes/blank'
require_relative 'toonrb/nodes/scalar'
require_relative 'toonrb/nodes/array'
require_relative 'toonrb/nodes/object'
require_relative 'toonrb/nodes/root'
require_relative 'toonrb/scanner'
require_relative 'toonrb/handler'
require_relative 'toonrb/generated_parser'
require_relative 'toonrb/parser'

##
# Toonrb: Toon decoder for Ruby
#
# Toon[https://toonformat.dev] is a structural text format optimized for LLM input.
# Toonrb is a Racc-based decoder gem that decodes Toon input into Ruby objects.
module Toonrb
  class << self
    ##
    # Decode the given Toon string into Ruby objects.
    #
    # Example:
    #
    #   toon = Toonrb.decode(<<~'TOON')
    #   context:
    #     task: Our favorite hikes together
    #     location: Boulder
    #     season: spring_2025
    #   friends[3]: ana,luis,sam
    #   hikes[3]{id,name,distanceKm,elevationGain,companion,wasSunny}:
    #     1,Blue Lake Trail,7.5,320,ana,true
    #     2,Ridge Overlook,9.2,540,luis,false
    #     3,Wildflower Loop,5.1,180,sam,true
    #   TOON
    #   # =>
    #   # {
    #   #   "context" => {
    #   #     "task" => "Our favorite hikes together",
    #   #     "location" => "Boulder", "season" => "spring_2025"
    #   #   },
    #   # ...
    #
    # Error Handling:
    #
    # Toonrb::ParseError is raised when the given Toon includes errors listed in
    # the {Toon spec}[https://github.com/toon-format/spec/blob/main/SPEC.md#14-strict-mode-errors-and-diagnostics-authoritative-checklist].
    #
    #   begin
    #     Toonrb.decode('freends[4]: ana,Luis,sam')
    #   rescue Toonrb::ParseError => e
    #     e
    #   end
    #   # => #<Toonrb::ParseError: expected 4 array items, but got 3 -- filename: unknown line: 1 column: 8>
    #
    # Arguments:
    #
    # +string_or_io+::
    #   String or IO object containing Toon string to be parsed.
    # +filename+::
    #   Filename string which is used for the exception message.
    #   (default: 'unknown')
    # +symbolize_names+::
    #   All hash keys are symbolized when this option is true.
    #   (default: false)
    # +strict+::
    #   The +strict+ mode is disabled and some error checks are not performed when this option is false.
    #   See the {Toon spec}[https://github.com/toon-format/spec/blob/main/SPEC.md#14-strict-mode-errors-and-diagnostics-authoritative-checklist]
    #   for more details.
    #   (default: true)
    # +path_expansion+::
    #   Dotted keys are split into nested objects when this option is true.
    #   See the {Toon spec}[https://github.com/toon-format/spec/blob/main/SPEC.md#decoder-path-expansion]
    #   for more details.
    #   (default: false)
    # +indent_size+::
    #   Indentation unit used to calucurate indentation depth.
    #   See the {Toon spec}[https://github.com/toon-format/spec/blob/main/SPEC.md#12-indentation-and-whitespace]
    #   for more details.
    #   (default: 2)
    # +debug+::
    #   Debug messages are displayed when this option is set to true.
    #   (default: false)
    def decode(
      string_or_io,
      filename: 'unknown', symbolize_names: false,
      strict: true, path_expansion: false, indent_size: 2, debug: false
    )
      toon =
        if string_or_io.is_a?(String)
          string_or_io
        else
          string_or_io.read
        end

      output = parse(toon, filename, strict, indent_size, debug)
      output.validate(strict:)
      output.to_ruby(symbolize_names:, strict:, path_expansion:)
    end

    ##
    # Similar to +Toonrb.decode+, but the Toon string is read from the file specified by the +filename+ argument.
    #
    # See also Toonrb.decode.
    def decode_file(filename, **optargs)
      File.open(filename, 'r:bom|utf-8') do |fp|
        decode(fp, filename:, **optargs)
      end
    end

    private

    def parse(toon, filename, strict, indent_size, debug)
      scanner = Scanner.new(toon, filename, strict, indent_size)
      handler = Handler.new
      parser = Parser.new(scanner, handler, debug:)
      parser.parse
    end
  end
end
