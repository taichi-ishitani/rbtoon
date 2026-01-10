# frozen_string_literal: true

module RbToon
  class Position # :nodoc:
    def initialize(filename, line, column)
      @filename = filename
      @line = line
      @column = column
    end

    attr_reader :filename
    attr_reader :line
    attr_reader :column

    def to_s
      "filename: #{filename} line: #{line} column: #{column}"
    end
  end

  class Token # :nodoc:
    def initialize(text, kind, depth, position)
      @text = text
      @kind = kind
      @depth = depth
      @position = position
    end

    attr_reader :text
    attr_reader :kind
    attr_reader :depth
    attr_reader :position
  end
end
