# frozen_string_literal: true

module Toonrb
  class Handler
    def initialize
      @stack = [Nodes::Root.new]
    end

    def output
      @stack.first
    end

    def push_object(key)
      object = Nodes::Object.new(key.position)
      push_value(object)

      @stack << object
      push_value(key, key: true)
    end

    def push_array(l_bracket_token, size)
      array = Nodes::Array.new(size, l_bracket_token.position)
      push_value(array)

      @stack << array
    end

    def push_value(value, **optargs)
      current.push_value(value, **optargs)
    end

    def push_blank(token, **optargs)
      return unless token

      blank = Nodes::Blank.new(token)
      push_value(blank, **optargs)
    end

    def push_empty_object(position)
      object = Nodes::EmptyObject.new(position)
      push_value(object)
    end

    def push_empty_array(position)
      array = Nodes::EmptyArray.new(position)
      push_value(array)
    end

    def pop
      @stack.pop
    end

    def quoted_string(token)
      Nodes::QuotedString.new(token)
    end

    def unquoted_string(token)
      Nodes::UnquotedString.new(token)
    end

    def empty_string(position)
      Nodes::EmptyString.new(position)
    end

    def boolean(token)
      Nodes::Boolean.new(token)
    end

    def null(token)
      Nodes::Null.new(token)
    end

    def number(token)
      Nodes::Number.new(token)
    end

    private

    def current
      @stack.last
    end
  end
end
