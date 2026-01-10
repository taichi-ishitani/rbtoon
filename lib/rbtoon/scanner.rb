# frozen_string_literal: true

module RbToon
  class Scanner # :nodoc:
    include RaiseParseError

    NL = / *\n/

    BLANK = /(?:^[ \t\n]*\n)|(?:^[ \t\n]+\z)/

    INDENT = /^[ \t]*/

    WHITE_SPACES = / +/

    L_BRACKET = /\[/

    R_BRACKET = /]/

    L_BRACE = /{/

    R_BRACE = /}/

    COLON = /(?:: )|(?::$)/

    HYPHEN = /(?:- )|(?:-$)/

    D_QUOTE = /"/

    BACK_SLASH = /\\/

    DELIMITER = /[,\t|]/

    BOOLEAN = /\A(?:true|false)\Z/

    NULL = /\Anull\Z/

    NUMBER = /\A-?(?:0|[1-9]\d*)(?:\.\d+)?(?:e[+-]?\d+)?\Z/i

    def initialize(string, filename, strict, indent_size)
      @ss = StringScanner.new(string)
      @filename = filename
      @line = 1
      @column = 1
      @delimiters = []
      @strict = strict
      @indent_size = indent_size.to_f
      @indent_depth = 0
      @layer_stack = []
      @array_depth = 0
      @list_array_depth = []
      @control_tokens = []
    end

    def next_token
      scan_control_tokens if @control_tokens.empty?

      token =
        if @control_tokens.empty?
          scan_code_token
        else
          @control_tokens.shift
        end
      token && [token.kind, token]
    end

    def push_array
      @array_depth += 1
      @delimiters << ','
      @delimiters << '|'
      @delimiters << "\t"
      push_layer(:array)
    end

    def pop_array
      @array_depth -= 1
      @delimiters.clear
      pop_layer
    end

    def start_list_array_items
      @delimiters.clear
    end

    def push_object
      push_layer(:object)
    end

    def pop_object
      pop_layer
    end

    def current_position
      create_position(@line, @column)
    end

    def delimiter(token)
      @delimiters.clear
      @delimiters << ((token && token.text[0]) || ',')
    end

    private

    def push_layer(layer)
      case @layer_stack.last
      in [Integer => depth, Array => layers] if depth == @indent_depth
        layers.push(layer)
      else
        @layer_stack.push([@indent_depth, [layer]])
      end
    end

    def pop_layer
      @layer_stack.pop
    end

    def object_as_list_item?(depth)
      index = @layer_stack.index { |(d, _)| depth == d }
      return false unless index
      return false unless index.positive? && object_layer?(@layer_stack[index])

      array_layer?(@layer_stack[index - 1])
    end

    def object_layer?(layer)
      _, layers = layer
      layers.first == :object
    end

    def array_layer?(layer)
      _, layers = layer
      layers.last == :array
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

    def scan_token(pattern, kind)
      text, line, column = scan(pattern)
      return unless text

      create_token(kind, text, line, column)
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

    def peek_char
      peek(/./)
    end

    def skip(pattern)
      text, _line, _column = scan(pattern)
      text&.length
    end

    def advance(char)
      @ss.pos += char.bytesize
      update_state(char)
    end

    def update_state(text)
      @line, @column = calc_next_position(text, @line, @column)
    end

    def calc_next_position(text, line, column)
      return [line, column] if text.empty?

      n_newlines = text.count("\n")
      next_line = line + n_newlines

      next_column =
        if text[-1] == "\n"
          1
        elsif n_newlines.positive?
          lines = text.split("\n")
          lines.last.length
        else
          column + text.length
        end

      [next_line, next_column]
    end

    def scan_control_tokens
      scan_nl
      scan_blank
      scan_indent
      scan_eos
    end

    def push_control_token(kind, text, line, column)
      return unless text

      token = create_token(kind, text, line, column)
      @control_tokens.push(token)
    end

    def scan_nl
      text, line, column = scan(NL)
      return unless text

      n_spaces = text.length - 1
      push_control_token(:NL, text[-1], line, column + n_spaces)
    end

    def scan_blank
      return if @column > 1 || eos?

      text, line, column = scan(BLANK)
      return unless text

      push_control_token(:BLANK, text, line, column)
    end

    def scan_indent
      return if @column > 1 || eos?

      indent, line, column = scan(INDENT)
      return unless indent

      check_tabs_in_indent(indent, line, column)
      check_indent_spaces_size(indent, line, column)

      next_depth = calc_next_depth(indent)
      update_indent_depth(next_depth)
    end

    def check_tabs_in_indent(indent, line, column)
      return unless @strict && indent.include?("\t")

      position = create_position(line, column)
      raise_parse_error 'tabs are not allowed in indentation', position
    end

    def check_indent_spaces_size(indent, line, column)
      return unless @strict && (indent.length % @indent_size).positive?

      position = create_position(line, column)
      message =
        "indentation must be exact multiple of #{@indent_size.to_i}, " \
        "but found #{indent.length} spaces"
      raise_parse_error message, position
    end

    def calc_next_depth(indent)
      next_depth = (indent.length / @indent_size).floor
      if object_as_list_item?(next_depth - 1)
        next_depth - 1
      else
        next_depth
      end
    end

    def update_indent_depth(next_depth)
      if @indent_depth > next_depth
        create_pop_indent_tokens(next_depth)
      elsif next_depth > @indent_depth
        create_push_indent_tokens(next_depth)
      end

      @indent_depth = next_depth
    end

    def create_pop_indent_tokens(next_depth)
      count = calc_indent_pop_count(next_depth)
      return unless count.positive?

      count.times do |i|
        column = ((@indent_depth - i) * @indent_size).to_i
        push_control_token(:POP_INDENT, '', @line, column)
      end
    end

    def calc_indent_pop_count(next_depth)
      offset = @layer_stack.count do |layer|
        depth, = layer
        next_depth <= depth &&
          (1...@indent_depth).include?(depth) &&
          object_as_list_item?(depth)
      end
      @indent_depth - next_depth - offset
    end

    def create_push_indent_tokens(next_depth)
      count = calc_indent_push_count(next_depth)
      return unless count.positive?

      count.times do |i|
        column = ((@indent_depth + i) * @indent_size).to_i
        push_control_token(:PUSH_INDENT, '', @line, column)
      end
    end

    def calc_indent_push_count(next_depth)
      base =
        if object_as_list_item?(@indent_depth)
          @indent_depth + 1
        else
          @indent_depth
        end
      next_depth - base
    end

    def scan_eos
      return unless eos?

      if @control_tokens.none? { |token| token.kind == :NL }
        # Parser requires all lines to be ended with NL.
        # Dummy NL is pushed if no NL exists before EOS.
        push_control_token(:NL, '', @line, @column)
      end

      update_indent_depth(0)

      push_control_token(:EOS, '', @line, @column)
      @control_tokens.push(nil)
    end

    def scan_code_token
      skip(WHITE_SPACES)

      token = scan_array_symbol
      return token if token

      token = scan_token(DELIMITER, :DELIMITER)
      return token if token

      token = scan_quoted_string
      return token if token

      scan_unquoted_string
    end

    def scan_array_symbol
      {
        L_BRACKET: L_BRACKET, R_BRACKET: R_BRACKET,
        L_BRACE: L_BRACE, R_BRACE: R_BRACE, COLON: COLON, HYPHEN: HYPHEN
      }.each do |kind, symbol|
        token = scan_token(symbol, kind)
        return token if token
      end

      nil
    end

    def scan_quoted_string
      return unless peek(/"/)

      line = @line
      column = @column

      buffer = []
      last_char = nil
      while (char = peek_char)
        break if char == "\n"

        advance(char)
        if char == '\\' && (escaped_char = scan_escaped_char)
          buffer << escaped_char
          last_char = [escaped_char, true]
        else
          buffer << char
          last_char = [char, false]
          break if buffer.size >= 2 && char == '"'
        end
      end

      # last char should be non-escaped double quort
      if buffer.size < 2 || last_char != ['"', false]
        position = create_position(@line, @column)
        raise_parse_error 'missing closing quote', position
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

      position = create_position(@line, @column - 1)
      raise_parse_error "invalid escape sequence: \\#{char}", position
    end

    def scan_unquoted_string
      line = @line
      column = @column

      buffer = []
      while (char = peek_char)
        break unless valid_unquoted_char?(char)

        advance(char)
        buffer << char
      end

      text = buffer.join.strip
      { BOOLEAN: BOOLEAN, NULL: NULL, NUMBER: NUMBER }.each do |kind, pattern|
        return create_token(kind, text, line, column) if pattern.match?(text)
      end

      create_token(:UNQUOTED_STRING, text, line, column)
    end

    def valid_unquoted_char?(char)
      return false if char == "\n" || match_delimiter?(char)

      [L_BRACKET, R_BRACKET, L_BRACE, R_BRACE, COLON, D_QUOTE, BACK_SLASH]
        .none? { |symbol| symbol.match?(char) }
    end

    def match_delimiter?(char)
      @delimiters.include?(char)
    end

    def create_token(kind, text, line, column)
      position = create_position(line, column)
      Token.new(text, kind, @indent_depth, position)
    end

    def create_position(line, column)
      Position.new(@filename, line, column)
    end
  end
end
