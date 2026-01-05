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

    private

    def current
      @stack.last
    end
  end
end
