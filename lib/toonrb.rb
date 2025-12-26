# frozen_string_literal: true

require 'strscan'

require_relative 'toonrb/version'
require_relative 'toonrb/token'
require_relative 'toonrb/nodes/node'
require_relative 'toonrb/nodes/scalar'
require_relative 'toonrb/nodes/array'
require_relative 'toonrb/nodes/root'
require_relative 'toonrb/scanner'
require_relative 'toonrb/generated_parser'
require_relative 'toonrb/parser'

module Toonrb
  class << self
    def load(string_or_io, filename: nil)
      toon =
        if string_or_io.is_a?(String)
          string_or_io
        else
          string_or_io.read
        end

      scanner = Scanner.new(toon, filename)
      parser = Parser.new(scanner)

      result = parser.parse
      result.to_ruby
    end
  end
end
