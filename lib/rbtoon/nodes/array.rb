# frozen_string_literal: true

module RbToon # :nodoc: all
  module Nodes
    class Array < StructureBase
      def initialize(parent, position, size)
        super(parent, position)
        @size = size
      end

      def push_tabular_fields(fields)
        @fields = fields
      end

      def validate(strict: true)
        if @fields
          validate_tabular_array(strict)
        else
          validate_array(strict)
        end
      end

      def to_ruby(symbolize_names: false, **optargs)
        values = non_blank_values
        result =
          if tabular?
            to_ruby_tabular(values, symbolize_names, **optargs)
          else
            to_ruby_list(values, symbolize_names, **optargs)
          end
        result || []
      end

      def kind
        :array
      end

      private

      def tabular?
        !@fields.nil?
      end

      def validate_tabular_array(strict)
        check_blank(strict, 'tabular rows')
        validate_array_size('tabular rows')
        validate_tabular_row_size
        @valus&.flatten&.each { |value| value.validate(strict:) }
      end

      def validate_array(strict)
        check_blank(strict, 'array')
        validate_array_size('array items')
        @values&.each { |value| value.validate(strict:) }
      end

      def validate_array_size(kind)
        actual = non_blank_values&.size || 0
        expected = @size.to_ruby
        return if actual == expected

        raise_parse_error "expected #{expected} #{kind}, but got #{actual}", position
      end

      def validate_tabular_row_size
        expected = @fields.size
        non_blank_values.each do |row|
          actual = row.size
          next if actual == expected

          position = row.position
          raise_parse_error "expected #{expected} tabular row items, but got #{actual}", position
        end
      end

      def to_ruby_tabular(rows, symbolize_names, **optargs)
        return unless rows

        fields = to_ruby_list(@fields, symbolize_names, **optargs)
        fields.map!(&:to_sym) if symbolize_names

        rows.map do |row|
          fields
            .zip(row.to_ruby(symbolize_names:, **optargs))
            .to_h
        end
      end

      def to_ruby_list(values, symbolize_names, **optargs)
        values&.map { |value| value.to_ruby(symbolize_names:, **optargs) }
      end
    end

    class TabularRow < Base
      def initialize(values, position)
        super(position)
        @values = values
      end

      def size
        @values.size
      end

      def to_ruby(**optargs)
        @values.map { |value| value.to_ruby(**optargs) }
      end

      def kind
        :tabular_row
      end
    end
  end
end
