# frozen_string_literal: true

module RbToon
  class Handler # :nodoc: all
    def initialize
      @stack = [Nodes::Root.new]
    end

    def output
      @stack.first
    end

    def push_object(key)
      object = Nodes::Object.new(current, key.position)
      push_value(object)

      @stack << object
      push_value(key)
    end

    def push_array(l_bracket_token, size)
      array = Nodes::Array.new(current, l_bracket_token.position, size)
      push_value(array)

      @stack << array
    end

    def push_value(value)
      current.push_value(value)
    end

    def push_values(values)
      values.each { |value| push_value(value) }
    end

    def push_tabular_fields(fields)
      current.push_tabular_fields(fields)
    end

    def push_tabular_row(values)
      row = Nodes::TabularRow.new(values, values.first.position)
      push_value(row)
    end

    def push_blank(token)
      return unless token

      blank = Nodes::Blank.new(token)
      push_value(blank)
    end

    def push_empty_object(position)
      object = Nodes::EmptyObject.new(position)
      push_value(object)
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
