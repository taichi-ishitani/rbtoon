# frozen_string_literal: true

module Toonrb
  module Nodes
    class Array < Base
      def initialize(size, position)
        super(position)
        @size = size
      end

      attr_reader :position

      def push_value(value, tabular_field: false, tabular_value: false, head_value: false)
        if tabular_field
          (@fields ||= []) << value
        elsif tabular_value
          (@values ||= []) << [] if head_value
          @values.last << value
        else
          (@values ||= []) << value
        end
      end

      def validate(strict:)
        if @fields
          validate_tabular_array(strict)
        else
          validate_array(strict)
        end
      end

      def to_ruby(**optargs)
        values = values_without_blank
        if tabular?
          fields = values_to_ruby(@fields, **optargs)
          values
            .map { |row| fields.zip(values_to_ruby(row, **optargs)).to_h }
        else
          values_to_ruby(values, **optargs) || []
        end
      end

      def kind
        :array
      end

      private

      def tabular?
        !@fields.nil?
      end

      def validate_tabular_array(strict)
        check_blank(strict, @values.map(&:first), 'tabular rows')
        validate_array_size('tabular rows')
        validate_tabular_row_size
        @valus&.flatten&.each { |value| value.validate(strict:) }
      end

      def validate_array(strict)
        check_blank(strict, @values, 'array')
        validate_array_size('array items')
        @values&.each { |value| value.validate(strict:) }
      end

      def check_blank(strict, values, kind)
        return unless strict && values

        blank = values.index { |value| value.kind == :blank }
        return unless blank

        non_blank = values.rindex { |value| value.kind != :blank }
        return unless non_blank

        return if non_blank < blank

        position = values[blank].position
        raise_parse_error "blank lines inside #{kind} are not allowed", position
      end

      def validate_array_size(kind)
        actual = values_without_blank&.size || 0
        expected = @size.to_ruby
        return if actual == expected

        raise_parse_error "expected #{expected} #{kind}, but got #{actual}", position
      end

      def validate_tabular_row_size
        expected = @fields.size
        @values.each do |row|
          actual = row.size
          next if actual == expected

          position = row.first.position
          raise_parse_error "expected #{expected} tabular row items, but got #{actual}", position
        end
      end

      def values_without_blank
        @values&.reject do |value|
          ((tabular? && value.first.kind) || value.kind) == :blank
        end
      end

      def values_to_ruby(values, **optargs)
        values&.map { |value| value.to_ruby(**optargs) }
      end
    end
  end
end
