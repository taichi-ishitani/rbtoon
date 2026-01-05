# frozen_string_literal: true

module Toonrb
  module Nodes
    class Root < Array
      def initialize
        super(nil, nil)
      end

      def validate(strict:)
        @values&.each_with_index do |value, i|
          i.positive? &&
            (raise_parse_error 'two or more values at root depth', value.position)
          value.validate(strict:)
        end
      end

      def to_ruby(**optargs)
        return {} unless @values

        @values.first.to_ruby(**optargs)
      end

      def kind
        :root
      end
    end
  end
end
