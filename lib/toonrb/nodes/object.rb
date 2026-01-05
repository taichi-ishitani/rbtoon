# frozen_string_literal: true

module Toonrb
  module Nodes
    class Object < Base
      attr_reader :position

      def push_value(value, key: false)
        if key
          (@keys ||= []) << value
        else
          (@values ||= []) << value
        end
      end

      def validate(strict:)
        @keys.zip(@values).each do |key, value|
          key.validate(strict:)
          value.validate(strict:)
        end
      end

      def to_ruby
        @keys
          .zip(@values)
          .to_h { |key, value| [key.to_ruby, value.to_ruby] }
      end

      def kind
        :object
      end
    end

    class EmptyObject < Base
      def to_ruby
        {}
      end

      def kind
        :empty_object
      end
    end
  end
end
