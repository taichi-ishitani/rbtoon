# frozen_string_literal: true

module Toonrb
  module Nodes
    class Object < StructureBase
      def validate(strict:)
        check_blank(strict, 'array')
        each_key_value do |key, value|
          key.validate(strict:)
          value.validate(strict:)
        end
      end

      def to_ruby(strict: true, path_expansion: false)
        each_key_value.with_object({}) do |(key, value), result|
          build_result(result, key, value, strict, path_expansion)
        end
      end

      def kind
        :object
      end

      private

      def each_key_value(&)
        if block_given?
          non_blank_values.each_slice(2, &)
        else
          non_blank_values.each_slice(2)
        end
      end

      def build_result(result, key, value, strict, path_expansion)
        k = key.to_ruby(strict:, path_expansion:)
        v = value.to_ruby(strict:, path_expansion:)

        paths = split_path(key, k, path_expansion)
        insert_value(result, paths, v, strict, key.position)
      end

      def split_path(key_node, key, path_expansion)
        if path_expansion && expandable_key?(key_node, key)
          key.split('.')
        else
          [key]
        end
      end

      def expandable_key?(key_node, key)
        key_node.unquoted_string? &&
          /\A[_a-z][_a-z0-9]*(?:\.[_a-z][_a-z0-9]*)*\Z/i.match?(key)
      end

      def insert_value(result, paths, value, strict, position)
        check_conflict(result, paths, value, strict, position)

        path = paths.first
        if paths.size > 1
          result[path] = {} unless result[path].is_a?(Hash)
          insert_value(result[path], paths[1..], value, strict, position)
        elsif [result[path], value] in [Hash, Hash]
          result[path].merge!(value)
        else
          result[path] = value
        end
      end

      def check_conflict(result, paths, value, strict, position)
        return unless conflict?(result, paths, value, strict)

        raise_parse_error "key conflict at \"#{paths.first}\"", position
      end

      def conflict?(result, paths, value, strict)
        path = paths.first
        return false unless strict && result.key?(path)

        if paths.size > 1
          !result[path].is_a?(Hash)
        elsif [result[path], value] in [Hash, Hash]
          !result[path].keys.intersect?(value.keys)
        else
          true
        end
      end
    end

    class EmptyObject < Base
      def to_ruby(**_optargs)
        {}
      end

      def kind
        :empty_object
      end
    end
  end
end
