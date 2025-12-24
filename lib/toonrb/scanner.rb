# frozen_string_literal: true

module Toonrb
  class Scanner
    BOOLEAN = /(?:true|false)\b/

    NULL = /null\b/

    NUMBER = /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:e[+-]?\d+)?\b/i

    def initialize(string, filename)
      @ss = StringScanner.new(string)
      @filename = filename
      @line = 1
      @column = 1
    end

    def next_token
      token = scan_token
      return [false, nil] unless token

      [token.kind, token]
    end

    private

    def scan_token
      return if eos?

      case
      when (text, line, column = scan_quoted_string)
        create_token(:QUOTED_STRING, text, line, column)
      when (text, line, column = scan(BOOLEAN))
        create_token(:BOOLEAN, text, line, column)
      when (text, line, column = scan(NULL))
        create_token(:NULL, text, line, column)
      when (text, line, column = scan(NUMBER))
        create_token(:NUMBER, text, line, column)
      when (text, line, column = scan_unquoted_string)
        create_token(:UNQUOTED_STRING, text, line, column)
      end
    end

    def eos?
      @ss.eos?
    end

    def scan(pattern)
      text = @ss.scan(pattern)
      return unless text

      line = @line
      column = @column

      update_state(text)

      [text, line, column]
    end

    def scan_char
      char = @ss.getch
      return unless char

      update_state(char)
      char
    end

    def scan_quoted_string
      return if @ss.peek(1) != '"'

      line = @line
      column = @column

      buffer = []
      while (char = scan_char)
        if char != '\\' || (char = scan_escaped_char)
          buffer << char
        end
      end

      if buffer.size < 2 || buffer.last != '"'
        # TODO
        # raise missing closing quote error
      end

      text = buffer.join
      [text, line, column]
    end

    def scan_escaped_char
      char = scan_char
      return unless char

      escaped_char =
        { '\\' => '\\', '"' => '"', 'n' => "\n", 'r' => "\r", 't' => "\t" }[char]
      return escaped_char if escaped_char

      # TODO
      # raise invalid escape sequence error
    end

    def scan_unquoted_string
      line = @line
      column = @column

      buffer = []
      while (char = scan_char)
        buffer << char

        break if @ss.peek(1) == "\n"
      end

      return nil if buffer.empty?

      text = buffer.join
      [text, line, column]
    end

    def update_state(text)
      @column += text.length
    end

    def create_token(kind, text, line, column)
      position = Position.new(@filename, line, column)
      Token.new(text, kind, position)
    end
  end
end
