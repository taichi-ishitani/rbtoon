# frozen_string_literal: true

module Toonrb
  class Scanner
    L_BRACKET = /\[/

    R_BRACKET = /]/

    L_BRACE = /{/

    R_BRACE = /}/

    COLON = /:/

    DELIMITER = /[,\t|]/

    BOOLEAN = /\A(?:true|false)\Z/

    NULL = /\Anull\Z/

    NUMBER = /\A-?(?:0|[1-9]\d*)(?:\.\d+)?(?:e[+-]?\d+)?\Z/i

    def initialize(string, filename)
      @ss = StringScanner.new(string)
      @delimiter = []
      @filename = filename
      @line = 1
      @column = 1
    end

    def next_token
      token = scan_token
      return [false, nil] unless token

      [token.kind, token]
    end

    def push_delimiter(delimiter)
      @delimiter << delimiter
    end

    def pop_delimiter
      @delimiter.pop
    end

    private

    def scan_token
      return if eos?

      token = scan_symbol
      return token if token

      token = scan_quoted_string
      return token if token

      scan_unquoted_string
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

    def peek(pattern)
      @ss.check(pattern)
    end

    def advance(char)
      @ss.pos += char.bytesize
      update_state(char)
    end

    def update_state(text)
      @column += text.length
    end

    def scan_symbol
      char = peek(/./)
      return unless char

      {
        L_BRACKET: L_BRACKET, R_BRACKET: R_BRACKET,
        L_BRACE: L_BRACE, R_BRACE: R_BRACE, COLON: COLON, DELIMITER: DELIMITER
      }.each do |kind, symbol|
        next unless symbol.match?(char)

        token = create_token(kind, char, @line, @column)
        advance(char)
        return token
      end

      nil
    end

    def scan_quoted_string
      return unless peek(/"/)

      line = @line
      column = @column

      buffer = []
      while (char = scan_char)
        if char == '\\' && (escaped_char = scan_escaped_char)
          buffer << escaped_char
        else
          buffer << char
          break if buffer.size >= 2 && char == '"'
        end
      end

      if buffer.size < 2 || buffer.last != '"'
        # TODO
        # raise missing closing quote error
      end

      text = buffer.join
      create_token(:QUOTED_STRING, text, line, column)
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
      while (char = peek(/./))
        break if match_header_symbol?(char) || match_eol?(char) || match_delimiter?(char)

        advance(char)
        buffer << char
      end

      text = buffer.join.strip
      { BOOLEAN: BOOLEAN, NULL: NULL, NUMBER: NUMBER }.each do |kind, pattern|
        return create_token(kind, text, line, column) if pattern.match?(text)
      end

      create_token(:UNQUOTED_STRING, text, line, column)
    end

    def match_header_symbol?(char)
      [L_BRACKET, R_BRACKET, L_BRACE, R_BRACE, COLON].any? { |symbol| symbol.match?(char) }
    end

    def match_eol?(char)
      char == "\n"
    end

    def match_delimiter?(char)
      return false if @delimiter.empty?

      char == @delimiter.last
    end

    def create_token(kind, text, line, column)
      position = Position.new(@filename, line, column)
      Token.new(text, kind, position)
    end
  end
end
