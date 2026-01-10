# frozen_string_literal: true

module RbToon # :nodoc: all
  module Nodes
    class Base
      include RaiseParseError

      def initialize(position)
        @position = position
      end

      attr_reader :position

      [
        :array, :tabular_row, :blank, :object, :empty_object,
        :root, :quoted_string, :unquoted_string, :empty_string,
        :boolean, :null, :number
      ].each do |kind|
        class_eval(<<~M, __FILE__, __LINE__ + 1)
          # def array?
          #   kind == :array
          # end
          def #{kind}?
            kind == :#{kind}
          end
        M
      end

      def validate(strict: true)
      end
    end

    class StructureBase < Base
      def initialize(parent, position)
        super(position)
        @parent = parent
      end

      attr_reader :parent

      def push_value(value)
        (@values ||= []) << value
      end

      private

      def non_blank_values
        @values&.reject(&:blank?)
      end

      def check_blank(strict, kind)
        return unless strict && @values && inside_array?

        blank =
          if parent.avove_array_edge?(self)
            @values.index(&:blank?)
          else
            @values[..-2].index(&:blank?)
          end
        return unless blank

        position = @values[blank].position
        raise_parse_error "blank lines inside #{kind} are not allowed", position
      end

      protected

      def inside_array?
        array? || parent&.inside_array? || false
      end

      def avove_array_edge?(object)
        return false unless inside_array?
        return true unless @values.last.equal?(object)

        parent.avove_array_edge?(self)
      end
    end
  end
end
