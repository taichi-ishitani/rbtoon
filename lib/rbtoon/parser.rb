# frozen_string_literal: true

module RbToon
  class Parser < GeneratedParser # :nodoc:
    include RaiseParseError

    def initialize(scanner, handler, debug: false)
      @scanner = scanner
      @handler = handler
      @yydebug = debug
      super()
    end

    def parse
      do_parse
      handler.output
    end

    private

    attr_reader :scanner
    attr_reader :handler

    def next_token
      scanner.next_token
    end

    def on_error(_token_id, value, _value_stack)
      message = "syntax error on value '#{value.text}' (#{value.kind})"
      raise_parse_error message, value.position
    end

    def to_list(val)
      [val[0], *val[1]&.map { |_, value| value }]
    end
  end
end
