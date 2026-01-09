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

module Toonrb
  class << self
    def decode(
      string_or_io,
      filename: nil, symbolize_names: false,
      strict: true, path_expansion: false, indent_size: 2
    )
      toon =
        if string_or_io.is_a?(String)
          string_or_io
        else
          string_or_io.read
        end

      scanner = Scanner.new(toon, filename, strict, indent_size)
      hander = Handler.new
      parser = Parser.new(scanner, hander, debug: false)

      output = parser.parse
      output.validate(strict:)
      output.to_ruby(symbolize_names:, strict:, path_expansion:)
    end

    def decode_file(filename, **optargs)
      File.open(filename, 'r:bom|utf-8') do |fp|
        decode(fp, filename:, **optargs)
      end
    end
  end
end
